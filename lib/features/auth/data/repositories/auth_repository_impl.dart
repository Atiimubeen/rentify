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

  // ... Implement other methods (signIn, signInWithGoogle, etc.) in a similar way

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
      return Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final auth.User? firebaseUser = await remoteDataSource.getCurrentUser();
        if (firebaseUser != null) {
          // This assumes user data is in Firestore. You'd need to fetch it.
          // For simplicity, we can create a basic entity here.
          // In a real app, you'd fetch from Firestore using the uid.
          return Right(
            UserEntity(
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              name: firebaseUser.displayName,
            ),
          );
        } else {
          return Right(null);
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      // If offline, check auth state locally
      final auth.User? firebaseUser = await remoteDataSource.getCurrentUser();
      if (firebaseUser != null) {
        return Right(
          UserEntity(
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            name: firebaseUser.displayName,
          ),
        );
      } else {
        return Right(null);
      }
    }
  }
}
