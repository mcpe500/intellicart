import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';
import 'package:intellicart/domain/usecases/get_current_user.dart';
import 'package:intellicart/domain/usecases/sign_out.dart';
import 'package:intellicart/domain/usecases/update_user.dart';
import 'package:intellicart/presentation/bloc/user/user_event.dart';
import 'package:intellicart/presentation/bloc/user/user_state.dart';

/// BLoC for managing user state.
///
/// This BLoC handles all user-related events and manages the state
/// of the current user in the application.
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetCurrentUser _getCurrentUser;
  final UpdateUser _updateUser;
  final SignOut _signOut;

  /// Creates a new user BLoC.
  UserBloc({
    required GetCurrentUser getCurrentUser,
    required UpdateUser updateUser,
    required SignOut signOut,
  })  : _getCurrentUser = getCurrentUser,
        _updateUser = updateUser,
        _signOut = signOut,
        super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<SignOutEvent>(_onSignOut);
  }

  /// Handles the LoadUser event.
  Future<void> _onLoadUser(
    LoadUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await _getCurrentUser();
      emit(UserLoaded(user));
    } on UserNotAuthenticatedException {
      emit(UserUnauthenticated());
    } on AppException catch (e) {
      emit(UserError(e.toString()));
    } catch (e) {
      emit(UserError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the UpdateUserEvent.
  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      final updatedUser = await _updateUser(event.user);
      emit(UserLoaded(updatedUser));
    } on AppException catch (e) {
      emit(UserError(e.toString()));
    } catch (e) {
      emit(UserError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the SignOutEvent.
  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _signOut();
      emit(UserUnauthenticated());
    } on AppException catch (e) {
      emit(UserError(e.toString()));
    } catch (e) {
      emit(UserError('An unexpected error occurred: ${e.toString()}'));
    }
  }
}