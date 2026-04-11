import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ProfileRepository profileRepository;

  StreamSubscription<Profile?>? _profileSubscription;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.profileRepository,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<CreateProfileEvent>(_onCreateProfile);
    on<SyncProfileEvent>(_onSyncProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    await _profileSubscription?.cancel();
    _profileSubscription = getProfileUseCase
        .watch(event.userId)
        .listen(
          (profile) {
            if (profile != null) {
              if (emit.isDone) return;
              emit(ProfileLoaded(profile: profile));
            }
          },
          onError: (error) {
            if (emit.isDone) return;
            emit(ProfileError(message: error.toString()));
          },
        );

    final profile = await getProfileUseCase(event.userId);
    if (profile != null) {
      emit(ProfileLoaded(profile: profile));
    } else {
      emit(ProfileNotFound());
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoaded(profile: event.profile, isSyncing: true));

      final updatedProfile = await updateProfileUseCase(event.profile);

      emit(ProfileUpdated(profile: updatedProfile));
      emit(ProfileLoaded(profile: updatedProfile, isSyncing: false));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onCreateProfile(
    CreateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final createdProfile = await profileRepository.createProfile(
        event.profile,
      );
      emit(ProfileLoaded(profile: createdProfile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onSyncProfile(
    SyncProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoaded(profile: event.profile, isSyncing: true));
      await profileRepository.syncProfile(event.profile);
      emit(ProfileLoaded(profile: event.profile, isSyncing: false));
    } catch (e) {
      emit(ProfileLoaded(profile: event.profile, isSyncing: false));
    }
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
