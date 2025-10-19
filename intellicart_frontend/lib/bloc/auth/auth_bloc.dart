import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart_frontend/data/repositories/auth_repository.dart';
// --- ADD THESE IMPORTS ---
import 'package:intellicart_frontend/data/datasources/api_service.dart';
import 'package:intellicart_frontend/models/user.dart';
// -------------------------

// Define AuthState classes here instead of as part files
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated();
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final String message;

  const AuthStateError(this.message);
  @override
  List<Object> get props => [message];
}

// Define events here as well
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });
  @override
  List<Object> get props => [email, password, name];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
  @override
  List<Object> get props => [];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  // --- ADD API SERVICE ---
  final ApiService _apiService;

  AuthBloc({AuthRepository? authRepository, ApiService? apiService}) // Modified constructor
      : _authRepository = authRepository ?? AuthRepositoryImpl(),
        _apiService = apiService ?? ApiService(), // Add this
        super(const AuthStateInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
    // Load initial auth state on startup
    on<CheckAuthStatus>(_onCheckAuthStatus);
    // Check authentication status when bloc is initialized
    add(CheckAuthStatus());
  }

  // --- REPLACED MOCK LOGIC WITH REAL LOGIC ---
  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading());
    try {
      // 1. Call the real ApiService
      final User? user = await _apiService.login(event.email, event.password);

      if (user != null) {
        // 2. Get the token from the service
        final String? token = _apiService.token;
        if (token != null) {
          // 3. Save the session persistently
          await _authRepository.saveAuthentication(token, user.id);
          // 4. Emit success
          emit(const AuthStateAuthenticated());
        } else {
          emit(const AuthStateError("Login successful but no token received."));
        }
      } else {
        // This case should ideally not be hit if ApiService throws exceptions
        emit(const AuthStateError("Login failed."));
      }
    } catch (e) {
      // ApiService throws ApiException, which we pass to the state
      emit(AuthStateError(e.toString()));
    }
  }

  // --- REPLACED MOCK LOGIC WITH REAL LOGIC ---
  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading());
    try {
      // 1. Clear the in-memory token
      _apiService.clearToken();
      // 2. Clear the persistent token
      await _authRepository.clearAuthentication();
      emit(const AuthStateUnauthenticated());
    } catch (e) {
      emit(AuthStateError(e.toString()));
    }
  }

  // --- REPLACED MOCK LOGIC WITH REAL LOGIC ---
  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading());
    try {
      // 1. Call the real ApiService
      final User user = await _apiService.register(
        event.email,
        event.password,
        event.name,
        'buyer', // Default to 'buyer' role on registration
      );

      // 2. Get the token from the service
      final String? token = _apiService.token;
      if (token != null) {
        // 3. Save the session persistently
        await _authRepository.saveAuthentication(token, user.id);
        // 4. Emit success
        emit(const AuthStateAuthenticated());
      } else {
        emit(const AuthStateError("Registration successful but no token received."));
      }
    } catch (e) {
      // ApiService throws ApiException, which we pass to the state
      emit(AuthStateError(e.toString()));
    }
  }

  // --- UPDATED TO REHYDRATE API SERVICE ---
  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading());
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        // 1. Load the persistent token
        final token = await _authRepository.getAuthToken();
        if (token != null) {
          // 2. Set the in-memory token for ApiService
          _apiService.setToken(token);
          emit(const AuthStateAuthenticated());
        } else {
          // Data is inconsistent, clear it
          await _authRepository.clearAuthentication();
          emit(const AuthStateUnauthenticated());
        }
      } else {
        emit(const AuthStateUnauthenticated());
      }
    } catch (e) {
      emit(AuthStateError(e.toString()));
    }
  }
}
