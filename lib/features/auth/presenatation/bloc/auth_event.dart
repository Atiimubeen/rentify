import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// App start hotay hi auth status check karne ke liye
class CheckAuthStatusEvent extends AuthEvent {}

// Sign up button dabanay par
class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  const SignUpEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
}

// Sign in button dabanay par
class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({required this.email, required this.password});
}

// Google sign in button dabanay par
class GoogleSignInEvent extends AuthEvent {}

// Logout button dabanay par
class SignOutEvent extends AuthEvent {}

// Role select karne par
class RoleSelectedEvent extends AuthEvent {
  final String role;
  const RoleSelectedEvent({required this.role});
}
