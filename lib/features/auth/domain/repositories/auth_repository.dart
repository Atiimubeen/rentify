import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  // Check karta hai ke user pehle se logged in hai ya nahi
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  // Email aur password se sign in karna
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  // Naya account banana
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  // Google se sign in karna
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  // Sign out karna
  Future<Either<Failure, void>> signOut();
}
