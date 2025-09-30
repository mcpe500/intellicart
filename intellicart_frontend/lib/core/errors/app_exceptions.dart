/// Base exception class for the application.
class AppException implements Exception {
  final String message;
  final String? prefix;
  final String? url;

  AppException([this.message = '', this.prefix = '', this.url = '']);

  @override
  String toString() {
    return '$prefix$message';
  }
}

/// Exception for network-related errors.
class NetworkException extends AppException {
  NetworkException([String? message]) : super(message, 'Network Error: ');
}

/// Exception for database-related errors.
class DatabaseException extends AppException {
  DatabaseException([String? message]) : super(message, 'Database Error: ');
}

/// Exception for validation errors.
class ValidationException extends AppException {
  ValidationException([String? message]) : super(message, 'Validation Error: ');
}

/// Exception for authentication errors.
class AuthenticationException extends AppException {
  AuthenticationException([String? message]) : super(message, 'Authentication Error: ');
}

/// Exception for product not found errors.
class ProductNotFoundException extends AppException {
  ProductNotFoundException([String? message]) : super(message, 'Product Not Found: ');
}

/// Exception for user not authenticated errors.
class UserNotAuthenticatedException extends AppException {
  UserNotAuthenticatedException([String? message])
      : super(message, 'User Not Authenticated: ');
}

/// Exception for cart-related errors.
class CartException extends AppException {
  CartException([String? message]) : super(message, 'Cart Error: ');
}