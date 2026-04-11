import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<User?> call() async {
    if (await repository.isAuthenticated() == false) {
      return Future.value(null);
    }

    final user = await repository.getCurrentUser();
    if (user == null) {
      return Future.value(null);
    }

    return repository.getCurrentUser();
  }
}
