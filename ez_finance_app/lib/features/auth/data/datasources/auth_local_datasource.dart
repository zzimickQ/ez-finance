import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<void> saveSessionToken(String token);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getSessionToken();
  Future<void> clearTokens();
  Future<bool> hasTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveAccessToken(String token) async {
    await secureStorage.write(key: 'access_token', value: token);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: 'refresh_token', value: token);
  }

  @override
  Future<void> saveSessionToken(String token) async {
    await secureStorage.write(key: 'session_token', value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: 'refresh_token');
  }

  @override
  Future<String?> getSessionToken() async {
    return await secureStorage.read(key: 'session_token');
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
    await secureStorage.delete(key: 'session_token');
  }

  @override
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final sessionToken = await getSessionToken();
    return accessToken != null || sessionToken != null;
  }
}
