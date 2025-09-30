# 01 - Setup Project Structure and Dependencies

## Overview
This step involves setting up the basic Flutter project structure following clean architecture principles and adding all necessary dependencies for the Intellicart application.

## Implementation Details

### 1. Create the Project Structure

First, we'll create the directory structure as defined in the specification:

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   ├── network/
│   └── services/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── bloc/
    ├── screens/
    ├── widgets/
    └── ai/
```

We'll create these directories using the file system:

```bash
mkdir -p lib/core/constants
mkdir -p lib/core/errors
mkdir -p lib/core/utils
mkdir -p lib/core/network
mkdir -p lib/core/services
mkdir -p lib/domain/entities
mkdir -p lib/domain/repositories
mkdir -p lib/domain/usecases
mkdir -p lib/data/datasources
mkdir -p lib/data/models
mkdir -p lib/data/repositories
mkdir -p lib/presentation/bloc
mkdir -p lib/presentation/screens
mkdir -p lib/presentation/widgets
mkdir -p lib/presentation/ai
```

### 2. Update pubspec.yaml with Dependencies

We need to add all the required dependencies to the `pubspec.yaml` file:

```yaml
name: intellicart
description: An intelligent shopping cart application with AI capabilities.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

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
  build_runner: ^2.4.6
```

### 3. Install Dependencies

After updating the `pubspec.yaml` file, we need to run:

```bash
flutter pub get
```

### 4. Setup Firebase Configuration

Initialize Firebase in the project by creating the necessary configuration files:

1. For Android: `android/app/google-services.json`
2. For iOS: `ios/Runner/GoogleService-Info.plist`

Also, initialize Firebase in the main.dart file:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

### 5. Setup Environment Variables

Create a `.env` file in the root directory for environment variables:

```env
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_APP_ID=your_app_id
```

Load the environment variables in the app:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // ... rest of initialization
}
```

## Verification

To verify this step is complete:

1. The directory structure should match the specification
2. All dependencies should be installed without errors
3. Firebase should be properly initialized
4. Environment variables should be accessible

## Implementation Checklist

- [x] Create project directory structure
- [x] Update pubspec.yaml with all required dependencies
- [x] Install dependencies using flutter pub get
- [x] Setup Firebase configuration files
- [x] Initialize Firebase in main.dart
- [x] Create .env file for environment variables
- [x] Load environment variables in the app
- [ ] Add continuous integration configuration
- [ ] Setup code formatting and linting rules
- [ ] Add documentation generation setup
- [ ] Configure testing environment
- [ ] Setup deployment scripts
- [ ] Add monitoring and logging setup
- [ ] Implement backup and recovery procedures

## Next Steps

After completing this step, we can move on to implementing the core domain entities (Product, CartItem, User).