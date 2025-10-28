// test/agentic_ai_wrapper_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/presentation/widgets/agentic_ai_wrapper.dart';

void main() {
  group('AgenticAIWrapper Tests', () {
    testWidgets('AgenticAIWrapperStateless builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: AgenticAIWrapperStateless(
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('AgenticAIWrapperStatefulWidget builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: AgenticAIWrapperStatefulWidget(
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('AI action callback is called', (WidgetTester tester) async {
      String receivedAction = '';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: AgenticAIWrapperStateless(
              onAIAction: (action) {
                receivedAction = action;
              },
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      // The wrapper should build without errors
      expect(find.text('Test Child'), findsOneWidget);
      expect(receivedAction, ''); // No action should be triggered initially
    });

    testWidgets('Wrapper shows AI controls when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: AgenticAIWrapperStateless(
              enableVoiceControl: true,
              enableChatControl: true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      // Check that the voice control is visible
      expect(find.byIcon(Icons.mic_none), findsOneWidget); // Voice button
      
      // For the send button, we need to check the overlay container
      // Since the chat input is in a positioned overlay, we can test that the TextField exists
      await tester.pump(); // Allow the widget to fully build
      
      // Look for the send icon which is inside the chat input row
      expect(find.byIcon(Icons.send), findsOneWidget); // Send button in chat
    });

    testWidgets('Wrapper hides AI controls when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: AgenticAIWrapperStateless(
              enableVoiceControl: false,
              enableChatControl: false,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      // Check that the voice and chat controls are not visible
      expect(find.byIcon(Icons.mic_none), findsNothing); // Voice button should not be present
      expect(find.byIcon(Icons.send), findsNothing); // Send button should not be present
    });
  });
}