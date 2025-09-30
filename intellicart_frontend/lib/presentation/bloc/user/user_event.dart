import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/user.dart';

/// Base class for all user events.
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

/// Event to load the current user.
class LoadUser extends UserEvent {}

/// Event to update the current user.
class UpdateUserEvent extends UserEvent {
  final User user;

  const UpdateUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

/// Event to sign out the current user.
class SignOutEvent extends UserEvent {}