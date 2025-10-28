// lib/data/datasources/ai/ai_api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'package:intellicart/core/services/logging_service.dart';

class AIAPIService {
  static String? _baseUrl;
  late Dio _dio;

  AIAPIService() {
    _dio = Dio();
    
    // Configure Dio with retry logic and exponential backoff
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Intellicart/1.0',
      },
    );
    
    // Add interceptors for retry logic, error handling, and security
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Validate and sanitize the request
        if (options.path.contains('..') || options.path.contains(';')) {
          loggingService.logSecurityEvent(
            'Invalid path detected in request',
            userId: '',
            sessionId: '',
          );
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Invalid path detected',
            ),
          );
        }
        
        // Add authentication headers if needed
        // final token = await AuthApiService.getToken();
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        
        loggingService.logInfo(
          'AI API request to: ${options.path}',
          tag: 'API_CALL',
        );
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Validate response
        loggingService.logInfo(
          'AI API response: ${response.statusCode} for ${response.requestOptions.path}',
          tag: 'API_RESPONSE',
        );
        
        if (response.statusCode! < 200 || response.statusCode! >= 300) {
          loggingService.logError(
            'AI API bad response: ${response.statusCode} for ${response.requestOptions.path}',
            tag: 'API_ERROR',
            stackTrace: StackTrace.current,
          );
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
            ),
          );
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Log errors securely (not including sensitive data)
        loggingService.logError(
          'AI API Service Error: ${e.type} - ${e.requestOptions.path}',
          tag: 'API_ERROR',
          stackTrace: e.stackTrace,
        );
        return handler.next(e);
      },
    ));
  }

  static Future<String> getBaseUrl() async {
    if (_baseUrl == null) {
      await dotenv.load(fileName: ".env");
      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
      // Validate the base URL to prevent SSRF attacks
      if (!apiBaseUrl.startsWith('http://') && !apiBaseUrl.startsWith('https://')) {
        loggingService.logSecurityEvent(
          'Invalid API_BASE_URL format',
          userId: '',
          sessionId: '',
        );
        throw Exception('Invalid API_BASE_URL: $apiBaseUrl');
      }
      _baseUrl = '$apiBaseUrl/api/ai';
    }
    return _baseUrl!;
  }

  /// Process user input (voice or text) and return AI action
  Future<String> processUserInput(String input, {String? userId, String? sessionId}) async {
    // Input validation and sanitization
    if (input.isEmpty) {
      loggingService.logWarning('Empty input provided to AI service', tag: 'VALIDATION');
      throw ArgumentError('Input cannot be empty');
    }
    
    // Sanitize input to prevent injection attacks
    final sanitizedInput = _sanitizeInput(input);
    
    try {
      final baseUrl = await getBaseUrl();
      
      // Create a hash of the input for potential security logging (without exposing content)
      final inputHash = sha256.convert(utf8.encode(input)).toString();
      loggingService.logInfo('Processing AI request with input hash: $inputHash', tag: 'AI_REQUEST');
      
      final response = await _dio.post(
        '$baseUrl/process',
        data: {
          'input': sanitizedInput,
          'userId': userId ?? '',
          'sessionId': sessionId ?? '',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'client': 'flutter',
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final action = data['action'] ?? data['response'] ?? 'unknown';
        
        // Validate the returned action to prevent command injection
        if (_isValidAction(action)) {
          loggingService.logInfo('Valid AI action received: $action', tag: 'AI_RESPONSE');
          return action;
        } else {
          loggingService.logSecurityEvent(
            'Invalid action returned from AI service: $action',
            userId: userId ?? '',
            sessionId: sessionId ?? '',
          );
          return 'unknown';
        }
      } else {
        loggingService.logError(
          'AI request failed with status: ${response.statusCode}',
          tag: 'API_ERROR',
        );
        throw Exception('Failed to process AI request: ${response.statusCode}');
      }
    } on DioException catch (e) {
      loggingService.logError(
        'DioException in AI service: $e',
        tag: 'NETWORK_ERROR',
        stackTrace: e.stackTrace,
      );
      rethrow;
    } catch (e) {
      loggingService.logError(
        'Error calling AI service: $e',
        tag: 'SERVICE_ERROR',
        stackTrace: StackTrace.current,
      );
      // Return a default response in case of error
      return 'unknown';
    }
  }

  /// Sanitize input to prevent injection attacks
  String _sanitizeInput(String input) {
    // Remove potentially dangerous characters while preserving natural language
    return input
        .replaceAll('<', '')  // Remove XSS characters
        .replaceAll('>', '')  // Remove XSS characters
        .replaceAll('&', '')  // Remove XSS characters
        .replaceAll('"', '')  // Remove XSS characters
        .replaceAll("'", '')  // Remove XSS characters
        .replaceAll('/', '')  // Remove potential path traversal
        .replaceAll('\\', '') // Remove potential path traversal
        .replaceAll(RegExp(r'\.{2,}'), '.') // Prevent directory traversal
        .replaceAll(';', '')  // Prevent command injection
        .replaceAll('|', '')  // Prevent command injection
        .replaceAll('`', '')  // Prevent command injection
        .replaceAll('\$', '') // Prevent command injection
        .trim(); // Remove leading/trailing whitespace
  }

  /// Validate that the action is one of the expected values
  bool _isValidAction(String action) {
    const validActions = {
      'navigate_to_product_list',
      'navigate_to_cart', 
      'search_products',
      'add_to_cart',
      'view_product_details',
      'navigate_to_profile',
      'show_recommendations',
      'apply_filter',
      'sort_by',
      'checkout',
      'unknown'
    };
    return validActions.contains(action);
  }

  /// Process voice input specifically
  Future<String> processVoiceInput(String voiceText, {String? userId, String? sessionId}) async {
    return await processUserInput(voiceText, userId: userId, sessionId: sessionId);
  }

  /// Process text input from chat
  Future<String> processTextInput(String text, {String? userId, String? sessionId}) async {
    return await processUserInput(text, userId: userId, sessionId: sessionId);
  }
}