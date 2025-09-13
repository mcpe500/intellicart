# 15 - Add Voice Interaction Capabilities

## Overview
This step involves adding voice interaction capabilities to the Intellicart application, allowing users to interact with the app through voice commands. We'll integrate the speech_to_text and flutter_tts packages to enable speech recognition and text-to-speech functionality.

## Implementation Details

### 1. Update pubspec.yaml with Voice Dependencies

First, let's add the necessary dependencies to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  flutter_bloc: ^8.1.1
  equatable: ^2.0.5
  firebase_core: ^2.14.0
  cloud_firestore: ^4.8.1
  firebase_auth: ^4.6.3
  firebase_storage: ^11.2.3
  firebase_messaging: ^14.6.3
  get_it: ^7.6.0
  flutter_dotenv: ^5.1.0
  http: ^0.17.0
  speech_to_text: ^6.1.1
  flutter_tts: ^3.6.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  mockito: ^5.4.0
  bloc_test: ^9.1.0
  build_runner: ^2.3.3
```

Then run:
```bash
flutter pub get
```

### 2. Create Voice Service

Create `lib/core/services/voice_service.dart`:

```dart
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  bool get isListening => _isListening;

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

  void startListening(Function(String) onResult) {
    if (!_isListening) {
      _isListening = true;
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
      );
    }
  }

  void stopListening() {
    if (_isListening) {
      _isListening = false;
      _speechToText.stop();
    }
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  void dispose() {
    stopListening();
    _speechToText.cancel();
  }
}
```

### 3. Update Service Locator with Voice Service

Update `lib/core/di/service_locator.dart`:

```dart
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intellicart/core/services/voice_service.dart';
import 'package:intellicart/data/datasources/product_firestore_data_source.dart';
import 'package:intellicart/data/datasources/user_firebase_data_source.dart';
import 'package:intellicart/data/datasources/cart_firestore_data_source.dart';
import 'package:intellicart/data/repositories/product_repository_impl.dart';
import 'package:intellicart/data/repositories/user_repository_impl.dart';
import 'package:intellicart/data/repositories/cart_repository_impl.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:intellicart/domain/repositories/user_repository.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/update_product.dart';
import 'package:intellicart/domain/usecases/delete_product.dart';
import 'package:intellicart/domain/usecases/search_products.dart';
import 'package:intellicart/domain/usecases/add_item_to_cart.dart';
import 'package:intellicart/domain/usecases/get_current_user.dart';
import 'package:intellicart/domain/usecases/auth/login_user.dart';
import 'package:intellicart/domain/usecases/auth/signup_user.dart';
import 'package:intellicart/domain/usecases/auth/logout_user.dart';
import 'package:intellicart/domain/usecases/process_natural_language_command.dart';
import 'package:intellicart/presentation/ai/natural_language_processor.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // Services
  sl.registerLazySingleton(() => VoiceService());

  // Data sources
  sl.registerLazySingleton<ProductFirestoreDataSource>(
    () => ProductFirestoreDataSource(firestore: sl()),
  );
  sl.registerLazySingleton<UserFirebaseDataSource>(
    () => UserFirebaseDataSource(auth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<CartFirestoreDataSource>(
    () => CartFirestoreDataSource(auth: sl(), firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(dataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllProducts(sl()));
  sl.registerLazySingleton(() => CreateProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => AddItemToCart(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SignupUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(
    () => ProcessNaturalLanguageCommand(
      processor: sl(),
      productRepository: sl(),
      cartRepository: sl(),
    ),
  );

  // AI components
  sl.registerLazySingleton(() => NaturalLanguageProcessor());
}
```

### 4. Update Home Screen with Voice Interaction

Update `lib/presentation/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/services/voice_service.dart';
import 'package:intellicart/core/di/service_locator.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_event.dart';
import 'package:intellicart/presentation/widgets/ai_command_input.dart';
import 'package:intellicart/presentation/widgets/product_list.dart';
import 'package:intellicart/presentation/screens/product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VoiceService _voiceService;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _voiceService = sl<VoiceService>();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    bool available = await _voiceService.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice service not available')),
        );
      }
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  void _startVoiceInput() {
    setState(() {
      _isListening = true;
    });

    _voiceService.startListening((text) {
      setState(() {
        _isListening = false;
      });
      
      // Dispatch the recognized text to AIInteractionBloc
      context.read<AIInteractionBloc>().add(
            ProcessNaturalLanguageCommandEvent(text),
          );
      
      // Speak a confirmation
      _voiceService.speak('I heard: $text. Processing your request.');
    });
  }

  void _stopVoiceInput() {
    setState(() {
      _isListening = false;
    });
    _voiceService.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intellicart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductBloc>().add(LoadProducts());
            },
          ),
          IconButton(
            icon: _isListening 
                ? const Icon(Icons.mic_off, color: Colors.red) 
                : const Icon(Icons.mic),
            onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 5. Update AI Command Input with Voice Feedback

Update `lib/presentation/widgets/ai_command_input.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/services/voice_service.dart';
import 'package:intellicart/core/di/service_locator.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_event.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_state.dart';

class AICommandInput extends StatefulWidget {
  const AICommandInput({super.key});

  @override
  State<AICommandInput> createState() => _AICommandInputState();
}

class _AICommandInputState extends State<AICommandInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late VoiceService _voiceService;

  @override
  void initState() {
    super.initState();
    _voiceService = sl<VoiceService>();
  }

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
            ProcessNaturalLanguageCommandEvent(_controller.text.trim()),
          );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
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
                icon: const Icon(Icons.send),
                onPressed: _submitCommand,
              ),
            ],
          ),
        ),
        // Listen to AI interaction state for voice feedback
        BlocListener<AIInteractionBloc, AIInteractionState>(
          listener: (context, state) {
            if (state is AIInteractionSuccess) {
              _voiceService.speak(state.message);
            } else if (state is AIInteractionError) {
              _voiceService.speak('Sorry, there was an error: ${state.message}');
            }
          },
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
```

### 6. Add Voice Permissions (Android)

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

    <queries>
        <intent>
            <action android:name="android.speech.RecognitionService" />
        </intent>
    </queries>

    <application
        android:label="intellicart"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 7. Add Voice Permissions (iOS)

Update `ios/Runner/Info.plist`:

```xml
<dict>
    <key>NSMicrophoneUsageDescription</key>
    <string>This application needs access to microphone for speech recognition</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>This application needs access to speech recognition</string>
    <!-- Other existing keys -->
</dict>
```

### 8. Create Voice Interaction Tutorial

Create `lib/presentation/screens/voice_tutorial_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:intellicart/core/services/voice_service.dart';
import 'package:intellicart/core/di/service_locator.dart';

class VoiceTutorialScreen extends StatefulWidget {
  const VoiceTutorialScreen({super.key});

  @override
  State<VoiceTutorialScreen> createState() => _VoiceTutorialScreenState();
}

class _VoiceTutorialScreenState extends State<VoiceTutorialScreen> {
  late VoiceService _voiceService;
  bool _isListening = false;
  String _recognizedText = '';
  final List<String> _examples = [
    'Add a keyboard to my cart',
    'Search for wireless mice',
    'Show me all electronics',
    'Create a new product called bluetooth speaker',
  ];

  @override
  void initState() {
    super.initState();
    _voiceService = sl<VoiceService>();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    bool available = await _voiceService.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice service not available')),
        );
      }
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });

    _voiceService.startListening((text) {
      setState(() {
        _recognizedText = text;
        _isListening = false;
      });
      
      _voiceService.speak('You said: $text');
    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _voiceService.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Tutorial'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Interaction Tutorial',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Try speaking one of these commands:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            ..._examples.map(
              (example) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    example,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  IconButton(
                    icon: CircleAvatar(
                      radius: 30,
                      backgroundColor: _isListening ? Colors.red : Colors.blue,
                      child: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    iconSize: 60,
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isListening ? 'Listening...' : 'Tap to speak',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_recognizedText.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'You said:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _recognizedText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 9. Update Home Screen to Include Voice Tutorial Access

Update `lib/presentation/screens/home_screen.dart` again:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/services/voice_service.dart';
import 'package:intellicart/core/di/service_locator.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_event.dart';
import 'package:intellicart/presentation/widgets/ai_command_input.dart';
import 'package:intellicart/presentation/widgets/product_list.dart';
import 'package:intellicart/presentation/screens/product_form_screen.dart';
import 'package:intellicart/presentation/screens/voice_tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VoiceService _voiceService;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _voiceService = sl<VoiceService>();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    bool available = await _voiceService.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice service not available')),
        );
      }
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  void _startVoiceInput() {
    setState(() {
      _isListening = true;
    });

    _voiceService.startListening((text) {
      setState(() {
        _isListening = false;
      });
      
      // Dispatch the recognized text to AIInteractionBloc
      context.read<AIInteractionBloc>().add(
            ProcessNaturalLanguageCommandEvent(text),
          );
      
      // Speak a confirmation
      _voiceService.speak('I heard: $text. Processing your request.');
    });
  }

  void _stopVoiceInput() {
    setState(() {
      _isListening = false;
    });
    _voiceService.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intellicart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceTutorialScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductBloc>().add(LoadProducts());
            },
          ),
          IconButton(
            icon: _isListening 
                ? const Icon(Icons.mic_off, color: Colors.red) 
                : const Icon(Icons.mic),
            onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Design Considerations

### 1. Platform-Specific Permissions
We've added the necessary permissions for both Android and iOS to access microphone and speech recognition services.

### 2. User Feedback
The voice interaction provides both visual and audio feedback to users, making it clear when the app is listening and what it has recognized.

### 3. Error Handling
The implementation includes proper error handling for cases where voice services are not available or fail to initialize.

### 4. Tutorial
We've included a tutorial screen to help users understand how to use voice commands effectively.

### 5. Integration with AI
Voice input is seamlessly integrated with the existing AI interaction system, allowing users to interact with the app through either text or voice.

## Verification

To verify this step is complete:

1. All voice-related files should exist in the appropriate directories
2. Voice service should be properly initialized and available
3. Voice input should work correctly and be integrated with the AI system
4. Text-to-speech should provide appropriate feedback to users
5. Platform-specific permissions should be properly configured
6. Tutorial screen should help users understand voice commands

## Code Quality Checks

1. All voice components should have proper documentation comments
2. Error handling should be comprehensive and user-friendly
3. Platform-specific code should be properly separated
4. The voice service should be properly integrated with the dependency injection system
5. Code should follow Flutter and Dart best practices

## Testing Voice Features

To test voice features:

1. Run the app on a physical device (voice features typically don't work in emulators)
2. Tap the microphone icon to start listening
3. Speak a command like "Add a keyboard to my cart"
4. Verify that the app recognizes the command and processes it
5. Check that the app provides audio feedback through text-to-speech

## Next Steps

After completing this step, all implementation steps for the Intellicart application are complete. The application now has:
- Clean architecture with proper separation of concerns
- BLoC state management
- Firebase integration for data persistence
- AI-powered natural language processing
- Comprehensive UI with responsive design
- Dependency injection for managing object creation
- Testing framework for quality assurance
- Error handling for robust operation
- Authentication flow for user management
- Voice interaction capabilities for hands-free operation