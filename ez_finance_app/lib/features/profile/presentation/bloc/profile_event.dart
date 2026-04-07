import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  final int userId;

  const LoadProfileEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateProfileEvent extends ProfileEvent {
  final Profile profile;

  const UpdateProfileEvent({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class CreateProfileEvent extends ProfileEvent {
  final Profile profile;

  const CreateProfileEvent({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class SyncProfileEvent extends ProfileEvent {
  final Profile profile;

  const SyncProfileEvent({required this.profile});

  @override
  List<Object?> get props => [profile];
}
