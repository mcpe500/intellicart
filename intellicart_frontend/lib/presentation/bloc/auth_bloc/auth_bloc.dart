// lib/presentation/bloc/auth_bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart/data/datasources/api_service.dart';
import 'package:intellicart/data/datasources/auth/auth_api_service.dart';
import 'package:intellicart/models/user.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const AuthLoginRequested(this.email, this.password);
  
  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;
  
  const AuthRegisterRequested(this.email, this.password, this.name, this.role);
  
  @override
  List<Object> get props => [email, password, name, role];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
  
  @override
  List<Object> get props => [];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
  
  @override
  List<Object> get props => [];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  
  const AuthAuthenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;
  
  AuthBloc({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService(),
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthCheckRequested>(_onCheckAuth);
    on<AuthLogoutRequested>(_onLogout);
    
    // Add an event to check auth status when bloc is initialized
    add(const AuthCheckRequested());
  }
  
  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc _onLogin called with email: ${event.email}');
    emit(const AuthLoading());
    
    try {
      final user = await _apiService.login(event.email, event.password);
      
      if (user != null) {
        print('AuthBloc login successful, user: ${user.name}');
        emit(AuthAuthenticated(user));
      } else {
        print('AuthBloc login failed - no user returned');
        emit(const AuthError('Invalid email or password'));
      }
    } catch (e) {
      print('AuthBloc login error: $e');
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc _onRegister called with email: ${event.email}, name: ${event.name}, role: ${event.role}');
    emit(const AuthLoading());
    
    try {
      final user = await _apiService.register(
        event.email,
        event.password,
        event.name,
        event.role,
      );
      
      if (user != null) {
        print('AuthBloc register successful, user: ${user.name}');
        emit(AuthAuthenticated(user));
      } else {
        print('AuthBloc register failed - no user returned');
        emit(const AuthError('Registration failed'));
      }
    } catch (e) {
      print('AuthBloc register error: $e');
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onCheckAuth(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final authApiService = AuthApiService();
      final isAuthenticated = await authApiService.verifyToken();
      if (isAuthenticated) {
        // If authenticated, get the current user
        final currentUser = await _apiService.getCurrentUser();
        
        if (currentUser != null) {
          emit(AuthAuthenticated(currentUser));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
  
  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final authApiService = AuthApiService();
      await authApiService.logout(); // Actually call the logout API
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}