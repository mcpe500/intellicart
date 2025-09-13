import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';
import 'package:intellicart/core/services/voice_service.dart';
import 'package:intellicart/domain/usecases/add_item_to_cart.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/presentation/ai/natural_language_processor.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_event.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_state.dart';

/// BLoC for managing AI interaction state.
///
/// This BLoC handles AI interaction events and manages the state
/// of natural language processing in the application.
class AIInteractionBloc extends Bloc<AIInteractionEvent, AIInteractionState> {
  final NaturalLanguageProcessor _processor;
  final GetAllProducts _getAllProducts;
  final AddItemToCart _addItemToCart;
  final VoiceService _voiceService;

  /// Creates a new AI interaction BLoC.
  AIInteractionBloc({
    required NaturalLanguageProcessor processor,
    required GetAllProducts getAllProducts,
    required AddItemToCart addItemToCart,
    required VoiceService voiceService,
  })  : _processor = processor,
        _getAllProducts = getAllProducts,
        _addItemToCart = addItemToCart,
        _voiceService = voiceService,
        super(AIInteractionInitial()) {
    on<ProcessNaturalLanguageCommand>(_onProcessNaturalLanguageCommand);
    on<ProcessVoiceCommand>(_onProcessVoiceCommand);
  }

  /// Handles the ProcessNaturalLanguageCommand event.
  Future<void> _onProcessNaturalLanguageCommand(
    ProcessNaturalLanguageCommand event,
    Emitter<AIInteractionState> emit,
  ) async {
    emit(AIInteractionProcessing());
    try {
      final action = await _processor.parseCommand(event.command);
      
      // Execute the action based on its type
      switch (action.type) {
        case ActionType.addToCart:
          // For simplicity, we'll just emit a success message
          // In a real implementation, this would interact with the cart BLoC
          emit(const AIInteractionSuccess('Added item to cart'));
          break;
        case ActionType.search:
          // For simplicity, we'll just emit a success message
          // In a real implementation, this would interact with the product BLoC
          emit(const AIInteractionSuccess('Searching for products'));
          break;
        case ActionType.createProduct:
          // For simplicity, we'll just emit a success message
          emit(const AIInteractionSuccess('Creating product'));
          break;
        case ActionType.viewCart:
          // For simplicity, we'll just emit a success message
          emit(const AIInteractionSuccess('Viewing cart'));
          break;
        case ActionType.checkout:
          // For simplicity, we'll just emit a success message
          emit(const AIInteractionSuccess('Checking out'));
          break;
        default:
          emit(const AIInteractionSuccess('Command processed'));
          break;
      }
    } on AppException catch (e) {
      emit(AIInteractionError(e.toString()));
    } catch (e) {
      emit(AIInteractionError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the ProcessVoiceCommand event.
  Future<void> _onProcessVoiceCommand(
    ProcessVoiceCommand event,
    Emitter<AIInteractionState> emit,
  ) async {
    emit(AIInteractionProcessing());
    try {
      // Start listening for voice input
      _voiceService.startListening((recognizedText) {
        if (recognizedText.isNotEmpty) {
          // Add a new event to process the recognized text
          add(ProcessNaturalLanguageCommand(recognizedText));
        }
      });
    } catch (e) {
      emit(AIInteractionError('Failed to start voice recognition: ${e.toString()}'));
    }
  }
}