// lib/data/datasources/ai/ai_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/logging_service.dart';

class AIAPIService {
  static String? _baseUrl;

  static Future<String> getBaseUrl() async {
    if (_baseUrl == null) {
      await dotenv.load(fileName: ".env");
      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
      _baseUrl = '$apiBaseUrl/api/ai';
    }
    return _baseUrl!;
  }

  /// Process user input (voice or text) and return AI action
  Future<String> processUserInput(String input, {String? userId, String? sessionId}) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/process'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'input': input,
          'userId': userId,
          'sessionId': sessionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['action'] ?? data['response'] ?? '';
      } else {
        throw Exception('Failed to process AI request: ${response.statusCode}');
      }
    } catch (e) {
      loggingService.logError('Error calling AI service: $e');
      // Return a default response in case of error
      return AIAction.unknown;
    }
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

/// Helper class to define AI actions that can be taken based on user input
class AIAction {
  static const String navigateToProductList = 'navigate_to_product_list';
  static const String navigateToCart = 'navigate_to_cart';
  static const String searchProducts = 'search_products';
  static const String addToCart = 'add_to_cart';
  static const String viewProductDetails = 'view_product_details';
  static const String navigateToProfile = 'navigate_to_profile';
  static const String showRecommendations = 'show_recommendations';
  static const String applyFilter = 'apply_filter';
  static const String sortBy = 'sort_by';
  static const String checkout = 'checkout';
  static const String unknown = 'unknown';
}