// lib/core/services/logging_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  File? _logFile;

  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, 'intellicart_logs.txt');
      _logFile = File(filePath);
      
      // Create the file if it doesn't exist
      if (!_logFile!.existsSync()) {
        await _logFile!.create();
      }
    } catch (e) {
      // Don't use logging service here since it's not initialized yet
      // Just print to console as fallback
      // ignore: avoid_print
      print('Failed to initialize logging: $e');
    }
  }

  void logInfo(String message, {String tag = 'INFO'}) {
    _writeLog('[$tag] ${DateTime.now()}: $message');
  }

  void logWarning(String message, {String tag = 'WARNING'}) {
    _writeLog('[$tag] ${DateTime.now()}: $message');
  }

  void logError(String message, {String tag = 'ERROR', StackTrace? stackTrace}) {
    String logMessage = '[$tag] ${DateTime.now()}: $message';
    if (stackTrace != null) {
      logMessage += '\nStack Trace: $stackTrace';
    }
    _writeLog(logMessage);
  }

  void logSecurityEvent(String event, {String userId = '', String sessionId = ''}) {
    // Create a hash of sensitive data to avoid exposing it in logs
    String userIdHash = userId.isNotEmpty ? sha256.convert(utf8.encode(userId)).toString() : '';
    String sessionIdHash = sessionId.isNotEmpty ? sha256.convert(utf8.encode(sessionId)).toString() : '';
    
    String logMessage = '[SECURITY] ${DateTime.now()}: $event | '
        'userIdHash: $userIdHash | sessionIdHash: $sessionIdHash';
    _writeLog(logMessage);
  }

  Future<void> _writeLog(String message) async {
    try {
      if (_logFile != null) {
        await _logFile!.writeAsString('$message\n', mode: FileMode.append);
      }
      // Also print to console in debug mode
      if (kDebugMode) {
        debugPrint(message);
      }
    } catch (e) {
      // Don't use logging service here since it might cause recursion
      // Just print to console as fallback
      // ignore: avoid_print
      print('Failed to write log: $e');
    }
  }

  Future<String> getLogContent() async {
    if (_logFile != null && await _logFile!.exists()) {
      return await _logFile!.readAsString();
    }
    return '';
  }

  Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('');
    }
  }
}

final loggingService = LoggingService();