import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.secureStorage,
  });

  @override
  Future<User> login(String email, String password) async {
    final authResponse = await remoteDataSource.login(email, password);

    await saveTokens(
      accessToken: authResponse.accessToken ?? '',
      refreshToken: authResponse.refreshToken,
      sessionToken: authResponse.sessionToken,
    );

    return _mapUserModelToEntity(authResponse.user!);
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      // Continue with local logout even if remote fails
    }
    await clearTokens();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return _mapUserModelToEntity(userModel);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await localDataSource.hasTokens();
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? sessionToken,
  }) async {
    await localDataSource.saveAccessToken(accessToken);
    if (refreshToken != null) {
      await localDataSource.saveRefreshToken(refreshToken);
    }
    if (sessionToken != null) {
      await localDataSource.saveSessionToken(sessionToken);
    }
  }

  @override
  Future<void> clearTokens() async {
    await localDataSource.clearTokens();
  }

  User _mapUserModelToEntity(UserModel model) {
    return User(
      id: model.id,
      email: model.email,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
