import 'package:equatable/equatable.dart';

/// Base class for all AI interaction states.
abstract class AIInteractionState extends Equatable {
  const AIInteractionState();

  @override
  List<Object> get props => [];
}

/// Initial state for the AI interaction BLoC.
class AIInteractionInitial extends AIInteractionState {}

/// State when processing an AI command.
class AIInteractionProcessing extends AIInteractionState {}

/// State when an AI command has been successfully processed.
class AIInteractionSuccess extends AIInteractionState {
  final String message;

  const AIInteractionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

/// State when there is an error processing an AI command.
class AIInteractionError extends AIInteractionState {
  final String message;

  const AIInteractionError(this.message);

  @override
  List<Object> get props => [message];
}