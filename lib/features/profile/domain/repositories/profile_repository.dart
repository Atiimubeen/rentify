import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  // User ki profile details haasil karna
  Future<Either<Failure, UserEntity>> getUserProfile(String uid);

  // User ki profile update karna (naam, phone number)
  Future<Either<Failure, void>> updateUserProfile(UserEntity user);

  // User ki profile picture upload karna
  Future<Either<Failure, String>> uploadProfilePicture(File image, String uid);
}
