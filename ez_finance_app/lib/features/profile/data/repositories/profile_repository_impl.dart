import 'package:rxdart/rxdart.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';

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
  Stream<Profile> watchProfile(String userId) {
    return localDataSource
        .watchProfile(userId)
        .doOnListen(() => _syncProfile(userId));
  }

  Future<void> _syncProfile(String userId) async {
    if (await localDataSource.getProfile(userId) != null) return;

    if (await networkInfo.isConnected) {
      try {
        final remoteProfile = await remoteDataSource.getProfile();
        if (remoteProfile != null) {
          await localDataSource.updateProfile(remoteProfile.toEntity());
        }
      } catch (e) {
        // Handle sync error (e.g., log it)
      }
    }
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

  Map<String, dynamic> _entityToJson(Profile profile) {
    return {
      'id': profile.id,
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'phone': profile.phone,
      'address': profile.address,
      'dateOfBirth': profile.dateOfBirth?.toIso8601String(),
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': profile.updatedAt.toIso8601String(),
      'version': profile.version,
    };
  }
}
