import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Profile> call(Profile profile) {
    return repository.updateProfile(profile);
  }
}
