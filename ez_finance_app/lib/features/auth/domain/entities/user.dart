import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, createdAt, updatedAt];
}
