import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile(String userId);
  Stream<Profile?> watchProfile(String userId);
  Future<Profile> createProfile(Profile profile);
  Future<Profile> updateProfile(Profile profile);
  Future<void> syncProfile(Profile profile);
  Future<void> syncAll();
}
