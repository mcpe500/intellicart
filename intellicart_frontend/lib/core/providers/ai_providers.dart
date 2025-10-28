// lib/core/providers/ai_providers.dart
import 'package:riverpod/riverpod.dart';
import 'package:intellicart/data/datasources/ai/ai_api_service.dart';

// AI API Service Provider
final aiApiServiceProvider = Provider<AIAPIService>((ref) {
  return AIAPIService();
});

// AI Action Provider - for managing the current AI action state
final aiActionProvider = StateProvider<String>((ref) => '');