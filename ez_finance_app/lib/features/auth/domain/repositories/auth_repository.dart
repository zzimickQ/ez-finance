import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? sessionToken,
  });
  Future<void> clearTokens();
}
