import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/network/network_info.dart';
import 'package:rentify/features/auth/data/models/user_model.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:rentify/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String uid) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.getUserProfile(uid);
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserEntity user) async {
    if (await networkInfo.isConnected) {
      try {
        // Cast UserEntity to UserModel for the data layer
        final userModel = UserModel(
          uid: user.uid,
          name: user.name,
          phone: user.phone,
          email: user.email,
          role: user.role,
        );
        await remoteDataSource.updateUserProfile(userModel);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(
    File image,
    String uid,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final url = await remoteDataSource.uploadProfilePicture(image, uid);
        return Right(url);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }
}
