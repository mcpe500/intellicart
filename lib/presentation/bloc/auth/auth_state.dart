import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/user.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Initial state for the authentication BLoC.
class AuthInitial extends AuthState {}

/// State when authentication is in progress.
class AuthLoading extends AuthState {}

/// State when the user is authenticated.
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// State when the user is unauthenticated.
class Unauthenticated extends AuthState {}

/// State when there is an authentication error.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}