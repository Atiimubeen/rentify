import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/profile/domain/usecases/get_user_profile.dart';
import 'package:rentify/features/profile/domain/usecases/update_user_profile.dart';
import 'package:rentify/features/profile/domain/usecases/upload_profile_picture.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final UploadProfilePicture _uploadProfilePicture;

  ProfileBloc({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required UploadProfilePicture uploadProfilePicture,
  }) : _getUserProfile = getUserProfile,
       _updateUserProfile = updateUserProfile,
       _uploadProfilePicture = uploadProfilePicture,
       super(ProfileInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadPictureEvent>(_onUploadPicture);
  }

  void _onFetchProfile(
    FetchProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _getUserProfile(GetUserProfileParams(event.uid));
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }

  void _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _updateUserProfile(
      UpdateUserProfileParams(event.user),
    );
    result.fold((failure) => emit(ProfileError(message: failure.message)), (_) {
      emit(ProfileUpdateSuccess());
      // Refresh profile data
      add(FetchProfileEvent(event.user.uid));
    });
  }

  void _onUploadPicture(
    UploadPictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _uploadProfilePicture(
      UploadProfilePictureParams(image: event.image, uid: event.uid),
    );
    result.fold((failure) => emit(ProfileError(message: failure.message)), (
      url,
    ) {
      emit(ProfileUpdateSuccess());
      // Refresh profile data
      add(FetchProfileEvent(event.uid));
    });
  }
}
