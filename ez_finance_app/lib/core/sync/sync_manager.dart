import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
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
  }) : _db = db,
       _apiClient = apiClient,
       _networkInfo = networkInfo {
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
    } catch (e) {
      print('Failed to pull remote changes: $e');
    }
  }

  Future<void> _mergeRemoteData(dynamic remoteData) async {
    if (remoteData is Map<String, dynamic>) {
      final remoteProfile = remoteData;
      final localProfile = await _db.getProfileByUserId(
        remoteProfile['user_id'] ?? 0,
      );

      if (localProfile == null) {
        await _saveRemoteProfile(remoteProfile);
      } else if (remoteProfile['updated_at'] != null &&
          localProfile.updatedAt.isBefore(
            DateTime.parse(remoteProfile['updated_at']),
          )) {
        await _saveRemoteProfile(remoteProfile);
      }
    }
  }

  Future<void> _saveRemoteProfile(Map<String, dynamic> data) async {
    await _db.insertProfile(
      ProfilesCompanion(
        id: Value(data['id']),
        firstName: Value(data['first_name']),
        lastName: Value(data['last_name']),
        phone: Value(data['phone']),
        address: Value(data['address']),
        dateOfBirth: Value(
          data['date_of_birth'] != null
              ? DateTime.parse(data['date_of_birth'])
              : null,
        ),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isSynced: const Value(true),
      ),
    );
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
