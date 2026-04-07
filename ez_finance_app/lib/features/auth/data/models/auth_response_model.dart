import 'package:equatable/equatable.dart';

class AuthResponseModel extends Equatable {
  final String? accessToken;
  final String? refreshToken;
  final String? sessionToken;
  final UserModel? user;

  const AuthResponseModel({
    this.accessToken,
    this.refreshToken,
    this.sessionToken,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      sessionToken: json['session_token'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'session_token': sessionToken,
      'user': user?.toJson(),
    };
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, sessionToken, user];
}

class UserModel extends Equatable {
  final int id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, email, name, avatarUrl, createdAt, updatedAt];
}
