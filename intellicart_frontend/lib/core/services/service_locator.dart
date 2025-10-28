// lib/core/services/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:intellicart/data/datasources/ai/ai_api_service.dart';

GetIt locator = GetIt.instance;

void setupServices() {
  // Register the AI API service
  locator.registerSingleton<AIAPIService>(
    AIAPIService(),
  );
}