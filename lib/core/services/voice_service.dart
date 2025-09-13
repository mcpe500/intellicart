import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// Service for handling voice interaction capabilities.
///
/// This service provides methods for speech recognition and text-to-speech functionality.
class VoiceService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  /// Whether the service is currently listening for speech.
  bool get isListening => _isListening;

  /// Initializes the voice service.
  Future<bool> initialize() async {
    try {
      // Initialize speech to text
      bool available = await _speechToText.initialize();
      
      // Initialize text to speech
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      
      return available;
    } catch (e) {
      return false;
    }
  }

  /// Starts listening for speech input.
  void startListening(Function(String) onResult) {
    if (!_isListening) {
      _isListening = true;
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _isListening = false;
            onResult(result.recognizedWords);
          }
        },
      );
    }
  }

  /// Stops listening for speech input.
  void stopListening() {
    if (_isListening) {
      _isListening = false;
      _speechToText.stop();
    }
  }

  /// Speaks the given text.
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  /// Stops speaking.
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }
}