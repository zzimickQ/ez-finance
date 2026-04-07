import '../../../../core/network/network_info.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final SyncManager syncManager;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.syncManager,
    required this.networkInfo,
  });

  @override
  Future<Profile?> getProfile(int userId) async {
    return await localDataSource.getProfile(userId);
  }

  @override
  Stream<Profile?> watchProfile(int userId) {
    return localDataSource.watchProfile(userId);
  }

  @override
  Future<Profile> createProfile(Profile profile) async {
    final createdProfile = await localDataSource.createProfile(profile);

    await syncManager.addToQueue(
      SyncOperation(
        entityType: 'profile',
        entityId: createdProfile.id,
        operation: 'insert',
        data: _entityToJson(createdProfile),
      ),
    );

    return createdProfile;
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final updatedProfile = await localDataSource.updateProfile(profile);

    await syncManager.addToQueue(
      SyncOperation(
        entityType: 'profile',
        entityId: updatedProfile.id,
        operation: 'update',
        data: _entityToJson(updatedProfile),
      ),
    );

    return updatedProfile;
  }

  @override
  Future<void> syncProfile(Profile profile) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    try {
      await remoteDataSource.updateProfile(_entityToModel(profile));
      await localDataSource.updateProfile(profile.copyWith(isSynced: true));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncAll() async {
    await syncManager.syncAll();
  }

  Map<String, dynamic> _entityToJson(Profile profile) {
    return {
      'id': profile.id,
      'user_id': profile.userId,
      'first_name': profile.firstName,
      'last_name': profile.lastName,
      'phone': profile.phone,
      'address': profile.address,
      'date_of_birth': profile.dateOfBirth?.toIso8601String(),
      'created_at': profile.createdAt.toIso8601String(),
      'updated_at': profile.updatedAt.toIso8601String(),
      'version': profile.version,
    };
  }

  ProfileModel _entityToModel(Profile profile) {
    return ProfileModel(
      id: profile.id,
      userId: profile.userId,
      firstName: profile.firstName,
      lastName: profile.lastName,
      phone: profile.phone,
      address: profile.address,
      dateOfBirth: profile.dateOfBirth,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      version: profile.version,
      isSynced: profile.isSynced,
    );
  }
}
