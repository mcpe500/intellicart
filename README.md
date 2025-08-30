# Intellicart

An intelligent shopping cart application with AI capabilities, built with Flutter.

## Features

- Cross-platform support (Android, iOS, Web, macOS, Windows, Linux)
- BLoC pattern for state management
- SQLite database for local data persistence
- REST API integration with offline capability
- Responsive UI design
- Unit and widget tests

## Architecture

The app follows clean architecture principles with a clear separation of concerns:

```
lib/
├── data/
│   ├── datasources/    # External data sources (API, database)
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
3. **Data Layer**: Contains implementations of repositories and data sources

### BLoC Pattern

The Business Logic Component (BLoC) pattern is used for state management:

- `product_bloc.dart` - Manages the business logic for product operations
- `product_event.dart` - Defines events that can be dispatched to the BLoC
- `product_state.dart` - Defines the different states the UI can be in

### Data Flow

1. UI triggers events (LoadProducts, CreateProduct, etc.)
2. ProductBloc processes events and manages state transitions
3. Use cases execute business logic
4. Repositories handle data access (API calls and database operations)
5. Entities represent the business data
6. UI updates based on state changes

## Dependencies

- `flutter_bloc` - For implementing the BLoC pattern
- `http` - For making HTTP requests to REST APIs
- `sqflite` - For SQLite database operations
- `path` - For handling file paths
- `equatable` - For value equality comparisons
- `flutter_dotenv` - For environment variable management
- `mockito` - For mocking in tests

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Testing

The app includes both unit tests and widget tests:

- `model_test.dart` - Tests for data models
- `usecase_test.dart` - Tests for use cases
- `widget_test.dart` - Tests for UI components

Run tests with `flutter test`.

## Offline Capability

The app implements offline capability by:

1. Storing data locally in SQLite database
2. Attempting to sync with the API when online
3. Falling back to local data when API is unavailable
4. Providing manual sync option via the refresh button

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.