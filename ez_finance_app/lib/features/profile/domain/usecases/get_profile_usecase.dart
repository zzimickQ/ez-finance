import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Profile?> call(int userId) {
    return repository.getProfile(userId);
  }

  Stream<Profile?> watch(int userId) {
    return repository.watchProfile(userId);
  }
}
