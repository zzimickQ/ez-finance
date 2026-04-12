import 'package:equatable/equatable.dart';
import 'package:ez_finance_app/features/profile/domain/entities/profile.dart';

class ProfileModel extends Equatable {
  final String id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    firstName,
    lastName,
    phone,
    address,
    dateOfBirth,
    createdAt,
    updatedAt,
  ];

  Profile toEntity() {
    return Profile(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
      dateOfBirth: dateOfBirth,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
