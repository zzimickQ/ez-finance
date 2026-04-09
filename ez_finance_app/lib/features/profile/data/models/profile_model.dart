import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String? id;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    print(json['id']);
    print(json['userId']);
    print(json['firstName']);
    print(json['lastName']);
    print(json['phone']);
    print(json['address']);
    print(json['dateOfBirth']);
    return ProfileModel(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    phone,
    address,
    dateOfBirth,
    createdAt,
    updatedAt,
  ];
}
