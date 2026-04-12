import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ez_finance_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ez_finance_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../database/app_database.dart';
import '../network/network_info.dart';

enum SyncStatus { idle, syncing, pending, offline, error }

class SyncOperation {
  final String entityType;
  final String entityId;
  final String operation;
  final Map<String, dynamic> data;
  final int priority;

  SyncOperation({
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    this.priority = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'data': data,
      'priority': priority,
    };
  }
}

class SyncManager {
  final AuthBloc _authBloc;
  final AppDatabase _db;
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final Uuid _uuid = const Uuid();

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  final StreamController<int> _pendingCountController =
      StreamController<int>.broadcast();

  Stream<SyncStatus> get syncStatus => _statusController.stream;
  Stream<int> get pendingCount => _pendingCountController.stream;

  bool _isSyncing = false;
  Timer? _periodicSyncTimer;

  SyncManager({
    required AppDatabase db,
    required ApiClient apiClient,
    required NetworkInfo networkInfo,
    required AuthBloc authBloc,
  }) : _db = db,
       _apiClient = apiClient,
       _networkInfo = networkInfo,
       _authBloc = authBloc {
    _init();
  }

  void _init() {
    _networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        syncAll();
      } else {
        _statusController.add(SyncStatus.offline);
      }
    });

    _updatePendingCount();
  }

  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(interval, (_) {
      syncAll();
    });
  }

  void stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }

  Future<void> addToQueue(SyncOperation operation) async {
    final id = _uuid.v4();
    await _db.insertSyncQueueItem(
      SyncQueueCompanion(
        operationId: Value(id),
        entityType: Value(operation.entityType),
        entityId: Value(operation.entityId),
        operation: Value(operation.operation),
        data: Value(jsonEncode(operation.data)),
        createdAt: Value(DateTime.now()),
        priority: Value(operation.priority),
      ),
    );

    _updatePendingCount();
    _checkAndSync();
  }

  Future<void> syncAll() async {
    if (_authBloc.state is! AuthAuthenticated) return;
    if (_isSyncing) return;

    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      _statusController.add(SyncStatus.offline);
      return;
    }

    _isSyncing = true;
    _statusController.add(SyncStatus.syncing);

    try {
      await _processSyncQueue();
      await _pullRemoteChanges();
      _statusController.add(SyncStatus.idle);
    } catch (e) {
      _statusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
      _updatePendingCount();
    }
  }

  Future<void> _processSyncQueue() async {
    final pendingItems = await _db.getPendingSyncQueueItems();

    for (final item in pendingItems) {
      try {
        await _executeOperation(item);
        await _db.deleteSyncQueueItem(item.id);
      } catch (e) {
        final updatedItem = SyncQueueData(
          id: item.id,
          operationId: item.operationId,
          entityType: item.entityType,
          entityId: item.entityId,
          operation: item.operation,
          data: item.data,
          createdAt: item.createdAt,
          retryCount: item.retryCount + 1,
          lastError: e.toString(),
          priority: item.priority,
        );
        await _db.updateSyncQueueItem(updatedItem);
      }
    }
  }

  Future<void> _executeOperation(SyncQueueData item) async {
    final data = jsonDecode(item.data) as Map<String, dynamic>;
    final endpoint = _getEndpoint(item.entityType, item.entityId);

    switch (item.operation) {
      case 'insert':
        await _apiClient.post(endpoint, data: data);
        break;
      case 'update':
        await _apiClient.put(endpoint, data: data);
        break;
      case 'delete':
        await _apiClient.delete(endpoint);
        break;
    }
  }

  String _getEndpoint(String entityType, String entityId) {
    switch (entityType) {
      case 'profile':
        return entityId == ''
            ? ApiEndpoints.profile
            : ApiEndpoints.profileById(entityId);
      default:
        return ApiEndpoints.profile;
    }
  }

  Future<void> _pullRemoteChanges() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      if (response.data != null) {
        await _mergeRemoteData(response.data);
      }
    } catch (e, stackTrace) {
      print('Failed to pull remote changes: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _mergeRemoteData(dynamic remoteData) async {
    if (remoteData is Map<String, dynamic>) {
      final remoteProfile = remoteData;
      final localProfile = await _db.getProfileByUserId(
        remoteProfile['userId'] ?? '',
      );

      if (localProfile == null) {
        await _saveRemoteProfile(remoteProfile);
      } else if (remoteProfile['updatedAt'] != null &&
          localProfile.updatedAt.isBefore(
            DateTime.parse(remoteProfile['updatedAt']),
          )) {
        await _saveRemoteProfile(remoteProfile);
      }
    }
  }

  Future<void> _saveRemoteProfile(Map<String, dynamic> data) async {
    var profilesCompanion = ProfilesCompanion(
      id: Value(data['id']),
      userId: Value(data['userId']),
      firstName: Value(data['firstName']),
      lastName: Value(data['lastName']),
      phone: Value(data['phone']),
      address: Value(data['address']),
      dateOfBirth: Value(
        data['dateOfBirth'] != null
            ? DateTime.parse(data['dateOfBirth'])
            : null,
      ),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isSynced: const Value(true),
    );
    await _db.insertProfile(profilesCompanion);
  }

  Future<void> _updatePendingCount() async {
    final items = await _db.getPendingSyncQueueItems();
    _pendingCountController.add(items.length);

    if (items.isNotEmpty && !_isSyncing) {
      _statusController.add(SyncStatus.pending);
    }
  }

  void _checkAndSync() async {
    final isConnected = await _networkInfo.isConnected;
    if (isConnected && !_isSyncing) {
      syncAll();
    }
  }

  Future<void> retrySync(int queueId) async {
    final items = await _db.getPendingSyncQueueItems();
    final item = items.firstWhere((e) => e.id == queueId);

    final updatedItem = SyncQueueData(
      id: item.id,
      operationId: item.operationId,
      entityType: item.entityType,
      entityId: item.entityId,
      operation: item.operation,
      data: item.data,
      createdAt: item.createdAt,
      retryCount: 0,
      lastError: null,
      priority: item.priority,
    );
    await _db.updateSyncQueueItem(updatedItem);

    syncAll();
  }

  void dispose() {
    _statusController.close();
    _pendingCountController.close();
    _periodicSyncTimer?.cancel();
  }
}
