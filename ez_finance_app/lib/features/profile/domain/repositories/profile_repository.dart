import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile(int userId);
  Stream<Profile?> watchProfile(int userId);
  Future<Profile> createProfile(Profile profile);
  Future<Profile> updateProfile(Profile profile);
  Future<void> syncProfile(Profile profile);
  Future<void> syncAll();
}
