import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Profile?> call(String userId) async {
    final profile = await repository.getProfile(userId);
    if (profile == null) {
      await repository.syncAll();
    }
    return profile;
  }

  Stream<Profile?> watch(String userId) {
    return repository.watchProfile(userId);
  }
}
