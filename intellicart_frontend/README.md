# IntelliCart

An intelligent shopping cart application with AI capabilities, built with Flutter. This comprehensive Flutter shopping cart application with intelligent features supporting multiple platforms (Android, iOS, Web, Windows, macOS, Linux).

## Features

- **Multi-platform Support**: Works on Android, iOS, Web, Windows, macOS, and Linux
- **BLoC Architecture**: Clean architecture with Business Logic Components for state management
- **Firebase Integration**: Real-time database and authentication, Firebase Storage for media assets, and Firebase Cloud Messaging (FCM) for push notifications
- **Location Services**: GPS and location-based features
- **Local Database**: SQLite for offline storage
- **Responsive UI**: Adapts to different screen sizes
- **Route Management**: Go Router for navigation
- **Theme Support**: Light and dark theme support
- **Unit and widget tests**

## Architecture

The app follows clean architecture principles with a clear separation of concerns:

```
lib/
├── data/
│   ├── datasources/    # Firebase data sources (Firestore, Auth, Storage)
│   ├── models/         # Data models (DTOs)
│   └── repositories/   # Repository implementations
├── domain/
│   ├── entities/       # Business entities
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Business logic
└── presentation/
    ├── bloc/           # BLoC pattern implementation
    ├── screens/        # UI screens
    └── widgets/        # Reusable UI components
```

### Clean Architecture Layers

1. **Presentation Layer**: Contains UI components and BLoC for state management  
2. **Domain Layer**: Contains business logic, entities, and repository interfaces  
3. **Data Layer**: Contains implementations of repositories and Firebase data sources  

### BLoC Pattern

The Business Logic Component (BLoC) pattern is used for state management:

- `product_bloc.dart` - Manages the business logic for product operations  
- `product_event.dart` - Defines events that can be dispatched to the BLoC  
- `product_state.dart` - Defines the different states the UI can be in  

### Data Flow

1. UI triggers events (LoadProducts, CreateProduct, etc.)  
2. ProductBloc processes events and manages state transitions  
3. Use cases execute business logic  
4. Repositories interact with Firebase (Firestore, Auth, Storage)  
5. Entities represent the business data  
6. UI updates based on state changes  

## Dependencies

- `flutter_bloc`: State management
- `equatable`: Value equality
- `sqflite`: SQLite database
- `firebase_core`: Firebase initialization
- `cloud_firestore`: Firestore database
- `firebase_auth`: For authentication  
- `firebase_storage`: For handling media assets  
- `firebase_messaging`: For push notifications  
- `location`: Device location services
- `go_router`: Navigation
- `flutter_screenutil`: Responsive UI
- `dio`: HTTP requests
- `json_annotation`: JSON serialization
- `flutter_dotenv`: For environment variable management  
- `mockito`: For mocking in tests  

## Getting Started

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd intellicart_frontend
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (for backend integration):
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add your platform (Android, iOS, Web) to the project
   - Download the configuration files:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`
     - Web: Add Firebase config to `web/index.html`

4. **Run the application**:
   ```bash
   flutter run
   ```

## Platform-specific Setup

### iOS
Add location permissions to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location to show nearby stores</string>
```

### macOS
Add location permissions to `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:
```xml
<key>com.apple.security.personal-information.location</key>
<true/>
```

## Testing

The app includes both unit tests and widget tests:

- `model_test.dart` - Tests for data models  
- `usecase_test.dart` - Tests for use cases  
- `widget_test.dart` - Tests for UI components  

Run tests with:
```bash
flutter test
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

### Windows, macOS, Linux
```bash
flutter build windows
flutter build macos
flutter build linux
```

## Offline Capability

Firestore provides offline persistence automatically:  

1. Data is cached locally and kept in sync when the device goes online  
2. Reads and writes work even when offline  
3. Changes are synchronized with the server when the connection is restored  

## Notes

- This is a starter project with placeholder implementations
- All BLoC patterns are set up but with simulated API calls
- SQLite and Firebase services are initialized but not fully implemented
- The UI is designed to be responsive and avoid overflow issues
- The project supports all requested platforms

Developers can now build upon this foundation to implement the actual features.
