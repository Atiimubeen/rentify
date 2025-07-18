import 'package:equatable/equatable.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// App start hotay waqt ki initial state
class AuthInitial extends AuthState {}

// Jab koi process chal raha ho (e.g., signing in)
class AuthLoading extends AuthState {}

// Jab user successfully login ho jaye
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

// Jab user login na ho ya logout kar de
class Unauthenticated extends AuthState {}

// Jab role select karna ho (e.g., Google sign-in ke baad)
class RoleSelectionRequired extends Authenticated {
  const RoleSelectionRequired({required super.user});
}

// Jab koi error aaye
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
