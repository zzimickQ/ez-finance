import 'package:ez_finance_app/core/utils/time_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final UserLocalDatasource userLocalDatasource;
  final TimeService timeService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.timeService,
    required this.userLocalDatasource,
  });

  @override
  Future<User> login(String email, String password) async {
    final authResponse = await remoteDataSource.login(email, password);

    await _saveTokens(
      accessToken: authResponse.accessToken ?? '',
      refreshToken: authResponse.refreshToken,
      sessionToken: authResponse.sessionToken,
    );

    final user = _mapUserModelToEntity(authResponse.user!);
    await userLocalDatasource.saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      // Continue with local logout even if remote fails
    }

    await localDataSource.clearTokens();
    await userLocalDatasource.clearUser();
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
    if (await localDataSource.hasTokens() == false) {
      return Future.value(false);
    }

    final refreshToken = await localDataSource.getRefreshToken();
    if (_isTokenExpired(refreshToken)) {
      return Future.value(false);
    }
    return await localDataSource.hasTokens();
  }

  bool _isTokenExpired(String? refreshToken) {
    if (refreshToken == null) return true;
    final expirationDate = JwtDecoder.getExpirationDate(refreshToken);
    return expirationDate.isBefore(timeService.getCurrentTime());
  }

  Future<void> _saveTokens({
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

  User _mapUserModelToEntity(UserModel model) {
    return User(
      id: model.id,
      email: model.email,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
