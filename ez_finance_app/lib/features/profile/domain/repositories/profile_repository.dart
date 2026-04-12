import '../entities/profile.dart';

abstract class ProfileRepository {
  Stream<Profile> watchProfile(String userId);
  Future<Profile> createProfile(Profile profile);
  Future<Profile> updateProfile(Profile profile);
}
