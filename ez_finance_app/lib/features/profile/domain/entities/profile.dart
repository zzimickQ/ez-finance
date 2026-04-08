import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final int id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isSynced;

  const Profile({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isSynced = false,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  Profile copyWith({
    int? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isSynced,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isSynced: isSynced ?? this.isSynced,
    );
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
