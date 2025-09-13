import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';
import 'package:intellicart/domain/entities/user.dart';
import 'package:intellicart/domain/usecases/get_current_user.dart';
import 'package:intellicart/domain/usecases/sign_out.dart';
import 'package:intellicart/domain/usecases/update_user.dart';
import 'package:intellicart/presentation/bloc/auth/auth_event.dart';
import 'package:intellicart/presentation/bloc/auth/auth_state.dart';

/// BLoC for managing authentication state.
///
/// This BLoC handles all authentication-related events and manages the state
/// of user authentication in the application.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser _getCurrentUser;
  final UpdateUser _updateUser;
  final SignOut _signOut;

  /// Creates a new authentication BLoC.
  AuthBloc({
    required GetCurrentUser getCurrentUser,
    required UpdateUser updateUser,
    required SignOut signOut,
  })  : _getCurrentUser = getCurrentUser,
        _updateUser = updateUser,
        _signOut = signOut,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Handles the AppStarted event.
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUser();
      emit(Authenticated(user));
    } on UserNotAuthenticatedException {
      emit(Unauthenticated());
    } on AppException catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the LoginRequested event.
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // In a real implementation, this would authenticate with a backend
      // For now, we'll just create a mock user
      final user = User(
        id: 1,
        email: event.email,
        name: 'Mock User',
      );
      emit(Authenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the SignUpRequested event.
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // In a real implementation, this would create a new user with a backend
      // For now, we'll just create a mock user
      final user = User(
        id: 1,
        email: event.email,
        name: event.name,
      );
      emit(Authenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the LogoutRequested event.
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _signOut();
      emit(Unauthenticated());
    } on AppException catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }
}