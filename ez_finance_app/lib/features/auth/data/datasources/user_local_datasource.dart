import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user.dart';

abstract class UserLocalDatasource {
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> clearUser();
}

class UserLocalDatasourceImpl implements UserLocalDatasource {
  final FlutterSecureStorage secureStorage;

  UserLocalDatasourceImpl({required this.secureStorage});

  @override
  Future<void> saveUser(User user) async {
    await secureStorage.write(key: 'user_id', value: user.id);
    await secureStorage.write(key: 'user_email', value: user.email);
    await secureStorage.write(
      key: 'user_created_at',
      value: user.createdAt.toIso8601String(),
    );
    await secureStorage.write(
      key: 'user_updated_at',
      value: user.updatedAt.toIso8601String(),
    );
  }

  @override
  Future<User?> getUser() async {
    final id = await secureStorage.read(key: 'user_id');
    final email = await secureStorage.read(key: 'user_email');
    final createdAt = await secureStorage.read(key: 'user_created_at');
    final updatedAt = await secureStorage.read(key: 'user_updated_at');

    if (id != null && email != null && createdAt != null && updatedAt != null) {
      return User(
        id: id,
        email: email,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );
    }

    throw Exception("No user found in local storage");
  }

  @override
  Future<void> clearUser() async {
    await secureStorage.delete(key: 'user_id');
    await secureStorage.delete(key: 'user_email');
    await secureStorage.delete(key: 'user_created_at');
    await secureStorage.delete(key: 'user_updated_at');
  }
}
