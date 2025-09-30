import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/widgets/ai_command_input.dart';
import 'package:intellicart/presentation/widgets/product_list.dart';

/// The main home screen of the application.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intellicart'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductBloc>().add(LoadProducts());
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              // Trigger voice input for AI interaction
              context.read<AIInteractionBloc>().add(ProcessVoiceCommand());
            },
          ),
        ],
      ),
      body: const Column(
        children: [
          AICommandInput(),
          Expanded(child: ProductList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add product screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}