import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthStateInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading());
    try {
      // TODO: Implement login logic with Firebase
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      emit(const AuthStateAuthenticated());
    } catch (e) {
      emit(AuthStateError(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading());
    try {
      // TODO: Implement logout logic with Firebase
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      emit(const AuthStateUnauthenticated());
    } catch (e) {
      emit(AuthStateError(e.toString()));
    }
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading());
    try {
      // TODO: Implement registration logic with Firebase
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      emit(const AuthStateAuthenticated());
    } catch (e) {
      emit(AuthStateError(e.toString()));
    }
  }
}
