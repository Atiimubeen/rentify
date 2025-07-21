import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/network/network_info.dart';
import 'package:rentify/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signUp(
          email: email,
          password: password,
          name: name,
          role: role,
        );
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signIn(
          email: email,
          password: password,
        );
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signInWithGoogle();
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final firebaseUser = await remoteDataSource.getCurrentUser();
      if (firebaseUser != null) {
        // Agar user login hai, to uska poora data Firestore se fetch karo
        final userModel = await remoteDataSource.getUserData(firebaseUser.uid);
        return Right(userModel);
      } else {
        // Agar koi user login nahi hai
        return const Right(null);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
