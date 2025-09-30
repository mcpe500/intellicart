import 'package:equatable/equatable.dart';

/// Base class for all AI interaction events.
abstract class AIInteractionEvent extends Equatable {
  const AIInteractionEvent();

  @override
  List<Object> get props => [];
}

/// Event to process a natural language command.
class ProcessNaturalLanguageCommand extends AIInteractionEvent {
  final String command;

  const ProcessNaturalLanguageCommand(this.command);

  @override
  List<Object> get props => [command];
}

/// Event to process a voice command.
class ProcessVoiceCommand extends AIInteractionEvent {}