import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// A service for logging and monitoring application events
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  /// Initialize logging services
  Future<void> initialize() async {
    // Initialize Firebase Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    
    // Initialize Crashlytics in non-debug builds
    if (kReleaseMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  }

  /// Log an info message
  void logInfo(String message, [Map<String, dynamic>? properties]) {
    debugPrint('INFO: $message');
    if (properties != null) {
      debugPrint('Properties: $properties');
    }
  }

  /// Log a warning message
  void logWarning(String message, [Map<String, dynamic>? properties]) {
    debugPrint('WARNING: $message');
    if (properties != null) {
      debugPrint('Properties: $properties');
    }
  }

  /// Log an error message
  void logError(String message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? properties]) {
    debugPrint('ERROR: $message');
    
    if (error != null) {
      debugPrint('Error: $error');
    }
    
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
    
    if (properties != null) {
      debugPrint('Properties: $properties');
    }
    
    // Send to Crashlytics in release mode
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(
        message,
        stackTrace ?? StackTrace.current,
        reason: message,
        information: properties?.entries
            .map((e) => '${e.key}: ${e.value}')
            .toList() ?? [],
      );
    }
  }

  /// Log a custom event for analytics
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    debugPrint('EVENT: $name');
    if (parameters != null) {
      debugPrint('Parameters: $parameters');
    }
    
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      logError('Failed to log analytics event', e);
    }
  }

  /// Log a user interaction
  Future<void> logUserInteraction(String interactionType, String target, [Map<String, dynamic>? additionalData]) async {
    final parameters = <String, dynamic>{
      'interaction_type': interactionType,
      'target': target,
      ...?additionalData,
    };
    
    await logEvent('user_interaction', parameters);
  }

  /// Log a screen view
  Future<void> logScreenView(String screenName, [Map<String, dynamic>? additionalData]) async {
    final parameters = <String, dynamic>{
      'screen_name': screenName,
      ...?additionalData,
    };
    
    await logEvent('screen_view', parameters);
    
    try {
      await FirebaseAnalytics.instance.logScreenView(
        screenName: screenName,
      );
    } catch (e) {
      logError('Failed to set current screen', e);
    }
  }
}