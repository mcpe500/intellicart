# IntelliCart Frontend

A comprehensive Flutter shopping cart application with intelligent features supporting multiple platforms (Android, iOS, Web, Windows, macOS, Linux).

## Features

- **Multi-platform Support**: Works on Android, iOS, Web, Windows, macOS, and Linux
- **BLoC Architecture**: Clean architecture with Business Logic Components
- **Firebase Integration**: Real-time database and authentication
- **Location Services**: GPS and location-based features
- **Local Database**: SQLite for offline storage
- **Responsive UI**: Adapts to different screen sizes
- **State Management**: Comprehensive state management with BLoC
- **Route Management**: Go Router for navigation
- **Theme Support**: Light and dark theme support

## Architecture

```
lib/
├── bloc/                    # Business Logic Components
│   ├── auth/               # Authentication logic
│   ├── cart/               # Shopping cart logic
│   ├── product/            # Product management
│   └── location/           # Location services
├── data/                   # Data models and repositories
│   ├── models/             # Data models
│   └── repositories/       # Data repositories
├── pages/                  # UI screens
│   ├── home/               # Home screen
│   ├── products/           # Product listing
│   ├── cart/               # Shopping cart
│   ├── profile/            # User profile
│   └── settings/           # App settings
├── services/               # Backend services
│   ├── database_service.dart  # SQLite operations
│   ├── firebase_service.dart  # Firebase operations
│   └── sensor_service.dart    # Device sensors
├── utils/                  # Utilities
│   ├── constants.dart      # App constants
│   ├── routes.dart         # Navigation routes
│   └── themes.dart         # App themes
├── widgets/                # Reusable UI components
│   └── common/             # Common widgets
└── main.dart               # App entry point
```

## Dependencies

- `flutter_bloc`: State management
- `equatable`: Value equality
- `sqflite`: SQLite database
- `firebase_core`: Firebase initialization
- `cloud_firestore`: Firestore database
- `location`: Device location services
- `go_router`: Navigation
- `flutter_screenutil`: Responsive UI
- `dio`: HTTP requests
- `json_annotation`: JSON serialization

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

## Project Structure Details

### BLoC (Business Logic Component)
- Separates business logic from UI
- Ensures testability and maintainability
- Handles state changes predictably

### Services
- `DatabaseService`: Handles local SQLite operations
- `FirebaseService`: Manages Firebase interactions
- `SensorService`: Handles device sensors (location, etc.)

### Pages
- `HomePage`: Main application dashboard
- `ProductsPage`: Product listing and search
- `CartPage`: Shopping cart management
- `ProfilePage`: User profile management
- `SettingsPage`: App settings

### Widgets
- Reusable UI components
- Follow Flutter best practices
- Consistent design system

## Development Guidelines

- Use BLoC for state management
- Follow Flutter's widget composition patterns
- Implement responsive design using constraints
- Handle errors gracefully
- Write unit and widget tests

## Testing

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

## Notes

- This is a starter project with placeholder implementations
- All BLoC patterns are set up but with simulated API calls
- SQLite and Firebase services are initialized but not fully implemented
- The UI is designed to be responsive and avoid overflow issues
- The project supports all requested platforms

Developers can now build upon this foundation to implement the actual features.