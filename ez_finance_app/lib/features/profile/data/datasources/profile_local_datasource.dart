import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/profile.dart' as entity;

abstract class ProfileLocalDataSource {
  Future<entity.Profile?> getProfile(int userId);
  Stream<entity.Profile?> watchProfile(int userId);
  Future<entity.Profile> createProfile(entity.Profile profile);
  Future<entity.Profile> updateProfile(entity.Profile profile);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final AppDatabase db;

  ProfileLocalDataSourceImpl({required this.db});

  @override
  Future<entity.Profile?> getProfile(int userId) async {
    final profile = await db.getProfileByUserId(userId);
    if (profile == null) return null;
    return _mapToEntity(profile);
  }

  @override
  Stream<entity.Profile?> watchProfile(int userId) {
    return db.watchProfileByUserId(userId).map((profile) {
      if (profile == null) return null;
      return _mapToEntity(profile);
    });
  }

  @override
  Future<entity.Profile> createProfile(entity.Profile profile) async {
    final id = await db.insertProfile(
      ProfilesCompanion.insert(
        userId: profile.userId,
        firstName: Value(profile.firstName),
        lastName: Value(profile.lastName),
        phone: Value(profile.phone),
        address: Value(profile.address),
        dateOfBirth: Value(profile.dateOfBirth),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return profile.copyWith(id: id);
  }

  @override
  Future<entity.Profile> updateProfile(entity.Profile profile) async {
    final updatedProfile = profile.copyWith(
      updatedAt: DateTime.now(),
      version: profile.version + 1,
      isSynced: false,
    );

    await db.updateProfile(
      Profile(
        id: updatedProfile.id,
        userId: updatedProfile.userId,
        firstName: updatedProfile.firstName,
        lastName: updatedProfile.lastName,
        phone: updatedProfile.phone,
        address: updatedProfile.address,
        dateOfBirth: updatedProfile.dateOfBirth,
        createdAt: updatedProfile.createdAt,
        updatedAt: updatedProfile.updatedAt,
        version: updatedProfile.version,
        isSynced: updatedProfile.isSynced,
        isDeleted: false,
      ),
    );

    return updatedProfile;
  }

  entity.Profile _mapToEntity(Profile profile) {
    return entity.Profile(
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
