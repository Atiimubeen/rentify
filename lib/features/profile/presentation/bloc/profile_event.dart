import 'dart:io';
import 'package:equatable/equatable.dart';

import 'package:rentify/features/auth/domain/entities/user_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

// User ki profile fetch karne ke liye
class FetchProfileEvent extends ProfileEvent {
  final String uid;
  const FetchProfileEvent(this.uid);
}

// Profile update karne ke liye
class UpdateProfileEvent extends ProfileEvent {
  final UserEntity user;
  const UpdateProfileEvent(this.user);
}

// Profile picture upload karne ke liye
class UploadPictureEvent extends ProfileEvent {
  final File image;
  final String uid;
  const UploadPictureEvent({required this.image, required this.uid});
}
