import 'package:intellicart_frontend/data/datasources/api_service.dart';
import 'package:intellicart_frontend/data/repositories/auth_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final ApiService apiService = ApiService();
  late final AuthRepository authRepository = AuthRepositoryImpl();

  // Get the current token from the shared API service
  String? get token => apiService.token;
  
  // Set the token in the shared API service
  void setToken(String? token) {
    if (token != null) {
      apiService.setToken(token);
    }
  }
  
  // Clear the token in the shared API service
  void clearToken() {
    apiService.clearToken();
  }
}

// Global instance
final serviceLocator = ServiceLocator();