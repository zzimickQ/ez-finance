import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;
  final bool isSyncing;

  const ProfileLoaded({required this.profile, this.isSyncing = false});

  @override
  List<Object?> get props => [profile, isSyncing];

  ProfileLoaded copyWith({Profile? profile, bool? isSyncing}) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileUpdated extends ProfileState {
  final Profile profile;

  const ProfileUpdated({required this.profile});

  @override
  List<Object?> get props => [profile];
}
