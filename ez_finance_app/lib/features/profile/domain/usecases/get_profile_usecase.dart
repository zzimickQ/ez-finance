import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Stream<Profile> call(String userId) {
    return repository.watchProfile(userId);
  }
}
