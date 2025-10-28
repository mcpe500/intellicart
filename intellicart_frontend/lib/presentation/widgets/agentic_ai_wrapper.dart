// lib/presentation/widgets/agentic_ai_wrapper.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intellicart/data/datasources/ai/ai_api_service.dart';
import 'package:intellicart/core/services/logging_service.dart';

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

/// A wrapper class for stateless widgets that enables AI-driven interactions
/// This allows users to interact via voice or chat instead of traditional UI controls
class AgenticAIWrapperStateless extends StatelessWidget {
  final Widget child;
  final String? aiPrompt;
  final bool enableVoiceControl;
  final bool enableChatControl;
  final void Function(String)? onAIAction;
  final AIAPIService? aiService; // For backend AI service integration

  const AgenticAIWrapperStateless({
    super.key,
    required this.child,
    this.aiPrompt,
    this.enableVoiceControl = true,
    this.enableChatControl = true,
    this.onAIAction,
    this.aiService,
  });

  @override
  Widget build(BuildContext context) {
    return AgenticAIWrapperStatefulWidget(
      child: child,
      aiPrompt: aiPrompt,
      enableVoiceControl: enableVoiceControl,
      enableChatControl: enableChatControl,
      onAIAction: onAIAction,
      aiService: aiService,
    );
  }
}

/// A wrapper class for stateful widgets that enables AI-driven interactions
/// This allows users to interact via voice or chat instead of traditional UI controls
class AgenticAIWrapperStatefulWidget extends StatefulWidget {
  final Widget child;
  final String? aiPrompt;
  final bool enableVoiceControl;
  final bool enableChatControl;
  final void Function(String)? onAIAction;
  final AIAPIService? aiService; // For backend AI service integration

  const AgenticAIWrapperStatefulWidget({
    super.key,
    required this.child,
    this.aiPrompt,
    this.enableVoiceControl = true,
    this.enableChatControl = true,
    this.onAIAction,
    this.aiService,
  });

  @override
  State<AgenticAIWrapperStatefulWidget> createState() => AgenticAIWrapperStatefulWidgetState();
}

class AgenticAIWrapperStatefulWidgetState extends State<AgenticAIWrapperStatefulWidget> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _lastRecognizedWords = '';
  final TextEditingController _textController = TextEditingController();
  bool _isProcessing = false;
  String _aiResponse = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      _speechToText = stt.SpeechToText();
      final isAvailable = await _speechToText.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
      if (isAvailable) {
        debugPrint('Speech recognition available');
      } else {
        debugPrint('Speech recognition not available');
        loggingService.logWarning('Speech recognition not available', tag: 'SPEECH');
      }
    } catch (e) {
      loggingService.logError('Failed to initialize speech recognition: $e', tag: 'SPEECH');
    }
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      try {
        final isAvailable = await _speechToText.initialize();
        if (isAvailable) {
          setState(() => _isListening = true);
          _speechToText.listen(
            onResult: (result) {
              if (mounted) {
                setState(() {
                  _lastRecognizedWords = result.recognizedWords;
                  if (result.finalResult) {
                    _processVoiceCommand(_lastRecognizedWords);
                    _isListening = false;
                  }
                });
              }
            },
          );
        } else {
          loggingService.logWarning('Speech recognition not available', tag: 'SPEECH');
        }
      } catch (e) {
        loggingService.logError('Error starting speech recognition: $e', tag: 'SPEECH');
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      try {
        _speechToText.stop();
        if (mounted) {
          setState(() => _isListening = false);
        }
      } catch (e) {
        loggingService.logError('Error stopping speech recognition: $e', tag: 'SPEECH');
      }
    }
  }

  Future<void> _processVoiceCommand(String command) async {
    if (command.isEmpty) return;

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _aiResponse = '';
      });
    }

    try {
      final String aiAction = await _getAIResponse(command, isVoice: true);
      if (widget.onAIAction != null) {
        widget.onAIAction!(aiAction);
      }
      
      if (mounted) {
        setState(() {
          _aiResponse = aiAction;
        });
      }
      loggingService.logInfo('Voice command processed successfully: $aiAction', tag: 'AI_COMMAND');
    } catch (e) {
      loggingService.logError('Error processing voice command: $e', tag: 'AI_COMMAND');
      if (mounted) {
        setState(() {
          _aiResponse = 'Sorry, I encountered an error processing your request.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processChatCommand() async {
    if (_textController.text.isEmpty) return;

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _aiResponse = '';
      });
    }

    try {
      final String aiAction = await _getAIResponse(_textController.text, isVoice: false);
      if (widget.onAIAction != null) {
        widget.onAIAction!(aiAction);
      }
      
      if (mounted) {
        setState(() {
          _aiResponse = aiAction;
          _textController.clear();
        });
      }
      loggingService.logInfo('Chat command processed successfully: $aiAction', tag: 'AI_COMMAND');
    } catch (e) {
      loggingService.logError('Error processing chat command: $e', tag: 'AI_COMMAND');
      if (mounted) {
        setState(() {
          _aiResponse = 'Sorry, I encountered an error processing your request.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Internal method to get AI response based on input
  Future<String> _getAIResponse(String input, {required bool isVoice}) async {
    if (widget.aiService != null) {
      // Use backend AI service
      return isVoice 
          ? await widget.aiService!.processVoiceInput(input)
          : await widget.aiService!.processTextInput(input);
    } else {
      // Use mock response for testing
      return _getMockAIResponse(input);
    }
  }

  // Mock response for testing without AI service
  String _getMockAIResponse(String input) {
    // Simple mock responses based on input
    final lowerInput = input.toLowerCase();
    if (lowerInput.contains('buy') || lowerInput.contains('cart')) {
      return AIAction.addToCart;
    } else if (lowerInput.contains('product') || lowerInput.contains('shop')) {
      return AIAction.navigateToProductList;
    } else if (lowerInput.contains('search') || lowerInput.contains('find')) {
      return AIAction.searchProducts;
    } else if (lowerInput.contains('profile') || lowerInput.contains('account')) {
      return AIAction.navigateToProfile;
    } else if (lowerInput.contains('checkout')) {
      return AIAction.checkout;
    } else if (lowerInput.contains('recommend') || lowerInput.contains('suggest')) {
      return AIAction.showRecommendations;
    } else if (lowerInput.contains('filter') || lowerInput.contains('sort')) {
      return AIAction.applyFilter;
    } else {
      return AIAction.unknown;
    }
  }

  @override
  void dispose() {
    try {
      _speechToText.stop();
      _textController.dispose();
    } catch (e) {
      loggingService.logError('Error during disposal: $e', tag: 'DISPOSAL');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The wrapped child widget
        widget.child,
        
        // AI interaction overlay
        if (widget.enableVoiceControl || widget.enableChatControl)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AI Response Display
                  if (_aiResponse.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _aiResponse,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  
                  // Processing indicator
                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Voice and Chat Controls
                  Row(
                    children: [
                      // Voice Control Button
                      if (widget.enableVoiceControl)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isListening ? _stopListening : _startListening,
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening ? Colors.red : Colors.white,
                            ),
                            label: Text(_isListening ? 'Listening...' : 'Voice'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isListening ? Colors.red : Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      
                      if (widget.enableVoiceControl && widget.enableChatControl)
                        const SizedBox(width: 8),
                      
                      // Chat Input
                      if (widget.enableChatControl)
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _textController,
                                    decoration: const InputDecoration(
                                      hintText: 'Ask AI...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    onSubmitted: (value) => _processChatCommand(),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: _processChatCommand,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}