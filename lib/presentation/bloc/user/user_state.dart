import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/user.dart';

/// Base class for all user states.
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

/// Initial state for the user BLoC.
class UserInitial extends UserState {}

/// State when the user is being loaded.
class UserLoading extends UserState {}

/// State when the user has been successfully loaded.
class UserLoaded extends UserState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object> get props => [user];
}

/// State when there is no authenticated user.
class UserUnauthenticated extends UserState {}

/// State when there is an error loading the user.
class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}