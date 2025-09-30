import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_event.dart';

/// Widget for entering natural language commands.
class AICommandInput extends StatefulWidget {
  const AICommandInput({super.key});

  @override
  State<AICommandInput> createState() => _AICommandInputState();
}

class _AICommandInputState extends State<AICommandInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitCommand() {
    if (_controller.text.trim().isNotEmpty) {
      // Dispatch the natural language command to AIInteractionBloc
      context.read<AIInteractionBloc>().add(
            ProcessNaturalLanguageCommand(_controller.text.trim()),
          );
      _controller.clear();
    }
  }

  void _startVoiceInput() {
    // Dispatch the voice command to AIInteractionBloc
    context.read<AIInteractionBloc>().add(ProcessVoiceCommand());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'Tell me what you need (e.g., "Add a keyboard to my cart")',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submitCommand(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: _startVoiceInput,
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitCommand,
          ),
        ],
      ),
    );
  }
}