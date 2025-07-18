import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/profile/domain/repositories/profile_repository.dart';

class UploadProfilePicture
    implements UseCase<String, UploadProfilePictureParams> {
  final ProfileRepository repository;

  UploadProfilePicture(this.repository);

  @override
  Future<Either<Failure, String>> call(
    UploadProfilePictureParams params,
  ) async {
    return await repository.uploadProfilePicture(params.image, params.uid);
  }
}

class UploadProfilePictureParams extends Equatable {
  final File image;
  final String uid;
  const UploadProfilePictureParams({required this.image, required this.uid});
  @override
  List<Object> get props => [image, uid];
}
