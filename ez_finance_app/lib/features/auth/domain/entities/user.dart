import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, name, avatarUrl, createdAt, updatedAt];
}
