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
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      sessionToken: json['sessionToken'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'sessionToken': sessionToken,
      'user': user?.toJson(),
    };
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, sessionToken, user];
}

class UserModel extends Equatable {
  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, email, createdAt, updatedAt];
}
