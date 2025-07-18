import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/auth/domain/usecases/get_current_user.dart';
import 'package:rentify/features/auth/domain/usecases/sign_in.dart';
import 'package:rentify/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:rentify/features/auth/domain/usecases/sign_out.dart';
import 'package:rentify/features/auth/domain/usecases/sign_up.dart';
// Note: You'll need to create a usecase for updating the user role
// import 'package:rentify/features/auth/domain/usecases/update_user_role.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser _getCurrentUser;
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final SignInWithGoogle _signInWithGoogle;
  // final UpdateUserRole _updateUserRole; // Add this later

  AuthBloc({
    required GetCurrentUser getCurrentUser,
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
    required SignInWithGoogle signInWithGoogle,
    // required UpdateUserRole updateUserRole,
  }) : _getCurrentUser = getCurrentUser,
       _signIn = signIn,
       _signUp = signUp,
       _signOut = signOut,
       _signInWithGoogle = signInWithGoogle,
       // _updateUserRole = updateUserRole,
       super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<SignOutEvent>(_onSignOut);
  }

  void _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) => user != null
          ? emit(Authenticated(user: user))
          : emit(Unauthenticated()),
    );
  }

  void _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signIn(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  void _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  void _onGoogleSignIn(GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signInWithGoogle(NoParams());
    result.fold((failure) => emit(AuthError(message: failure.message)), (user) {
      if (user.role == null) {
        // New user from Google, needs to select a role
        emit(RoleSelectionRequired(user: user));
      } else {
        // Existing user from Google
        emit(Authenticated(user: user));
      }
    });
  }

  void _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _signOut(NoParams());
    emit(Unauthenticated());
  }
}
