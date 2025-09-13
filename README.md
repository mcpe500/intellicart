# Intellicart

An intelligent shopping cart application with AI capabilities, built with Flutter.

## Features

- Cross-platform support (Android, iOS, Web, macOS, Windows, Linux)
- BLoC pattern for state management
- Firebase Authentication for user management
- Cloud Firestore for real-time database
- Firebase Storage for media assets
- Firebase Cloud Messaging (FCM) for push notifications
- Responsive UI design
- Unit and widget tests

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

- `flutter_bloc` - For implementing the BLoC pattern  
- `cloud_firestore` - For Firestore database operations  
- `firebase_auth` - For authentication  
- `firebase_storage` - For handling media assets  
- `firebase_messaging` - For push notifications  
- `equatable` - For value equality comparisons  
- `flutter_dotenv` - For environment variable management  
- `mockito` - For mocking in tests  

## Getting Started

1. Clone the repository  
2. Run `flutter pub get` to install dependencies  
3. Set up Firebase project and add your platform-specific configuration (GoogleServices-Info.plist, google-services.json, etc.)  
4. Run `flutter run` to start the application  

## Testing

The app includes both unit tests and widget tests:

- `model_test.dart` - Tests for data models  
- `usecase_test.dart` - Tests for use cases  
- `widget_test.dart` - Tests for UI components  

Run tests with `flutter test`.

## Offline Capability

Firestore provides offline persistence automatically:  

1. Data is cached locally and kept in sync when the device goes online  
2. Reads and writes work even when offline  
3. Changes are synchronized with the server when the connection is restored

## Backup and Recovery

The application includes comprehensive backup and recovery capabilities:

- Automatic database backups
- Manual backup and restore operations
- JSON export/import functionality
- Backup management (list, delete)

See [Backup Documentation](lib/core/services/backup/README.md) for more details.  
