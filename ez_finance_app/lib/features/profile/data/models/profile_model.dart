import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final int? id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;
  final bool? isSynced;

  const ProfileModel({
    this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.isSynced,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      version: json['version'] as int?,
      isSynced: json['is_synced'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address': address,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'version': version,
      'is_synced': isSynced,
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
    version,
    isSynced,
  ];
}
