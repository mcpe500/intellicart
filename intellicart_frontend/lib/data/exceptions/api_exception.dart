// lib/data/exceptions/api_exception.dart

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? serverMessage;
  
  ApiException(this.statusCode, this.message, {this.serverMessage});
  
  factory ApiException.fromDioException(DioException e) {
    String message = "An unknown error occurred";
    String? serverMessage;
    
    // Extract server message if available
    if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      serverMessage = data['message'] ?? data['error'];
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(0, "Connection timeout", serverMessage: serverMessage);
      case DioExceptionType.sendTimeout:
        return ApiException(0, "Send timeout", serverMessage: serverMessage);
      case DioExceptionType.receiveTimeout:
        return ApiException(0, "Receive timeout", serverMessage: serverMessage);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        
        switch (statusCode) {
          case 200:
          case 201:
          case 204:
            // These should not trigger errors, but if they do, it might be a logic error
            return ApiException(statusCode, "Unexpected response", serverMessage: serverMessage);
          case 400:
            return ApiException(statusCode, "Bad request - Please check your input", serverMessage: serverMessage);
          case 401:
            return ApiException(statusCode, "Unauthorized - Please log in again", serverMessage: serverMessage);
          case 403:
            return ApiException(statusCode, "Forbidden - You don't have permission to access this resource", serverMessage: serverMessage);
          case 404:
            return ApiException(statusCode, "Resource not found", serverMessage: serverMessage);
          case 409:
            return ApiException(statusCode, "Conflict - The request could not be completed due to a conflict", serverMessage: serverMessage);
          case 422:
            return ApiException(statusCode, "Unprocessable entity - Validation error", serverMessage: serverMessage);
          case 429:
            return ApiException(statusCode, "Too many requests - Please try again later", serverMessage: serverMessage);
          case 500:
            return ApiException(statusCode, "Internal server error - Please try again later", serverMessage: serverMessage);
          case 502:
            return ApiException(statusCode, "Bad gateway - Server temporarily unavailable", serverMessage: serverMessage);
          case 503:
            return ApiException(statusCode, "Service unavailable - Server is temporarily unavailable", serverMessage: serverMessage);
          case 504:
            return ApiException(statusCode, "Gateway timeout", serverMessage: serverMessage);
          default:
            return ApiException(statusCode, e.response?.statusMessage ?? "Server error", serverMessage: serverMessage);
        }
      case DioExceptionType.cancel:
        return ApiException(0, "Request cancelled", serverMessage: serverMessage);
      case DioExceptionType.badCertificate:
        return ApiException(0, "Bad certificate", serverMessage: serverMessage);
      case DioExceptionType.connectionError:
        return ApiException(0, "Connection error", serverMessage: serverMessage);
      default:
        return ApiException(0, "Something went wrong", serverMessage: serverMessage);
    }
  }
}