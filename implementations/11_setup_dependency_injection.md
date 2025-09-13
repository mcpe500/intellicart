# 11 - Setup Dependency Injection

## Overview
This step involves setting up dependency injection using the `get_it` package to manage object creation and dependencies throughout our application. This will allow us to easily manage singleton instances and dependencies between different layers of our application.

## Implementation Details

### 1. Create the Service Locator

Create `lib/core/di/service_locator.dart`:

```dart
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:intellicart/domain/usecases/process_natural_language_command.dart';
import 'package:intellicart/presentation/ai/natural_language_processor.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

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

### 2. Update Main Application to Initialize Dependencies

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intellicart/core/di/service_locator.dart' as di;
import 'package:intellicart/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init(); // Initialize dependency injection
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intellicart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
```

### 3. Create BLoC Providers

Create `lib/presentation/bloc/bloc_providers.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/di/service_locator.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/cart/cart_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';

class BlocProviders extends StatelessWidget {
  final Widget child;

  const BlocProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductBloc(
            getAllProducts: sl(),
            createProduct: sl(),
            updateProduct: sl(),
            deleteProduct: sl(),
            searchProducts: sl(),
          ),
        ),
        BlocProvider(
          create: (context) => CartBloc(
            cartRepository: sl(),
            addItemToCart: sl(),
          ),
        ),
        BlocProvider(
          create: (context) => AIInteractionBloc(
            processCommand: sl(),
            productBloc: context.read<ProductBloc>(),
            cartBloc: context.read<CartBloc>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
```

### 4. Update Main Application to Include BLoC Providers

Update `lib/main.dart` again:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intellicart/core/di/service_locator.dart' as di;
import 'package:intellicart/presentation/bloc/bloc_providers.dart';
import 'package:intellicart/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init(); // Initialize dependency injection
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProviders(
      child: MaterialApp(
        title: 'Intellicart',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
```

## Design Considerations

### 1. Lazy Singleton Registration
We're using lazy singleton registration for most dependencies, which means objects are only created when they're first requested. This helps with performance and memory usage.

### 2. Layered Dependencies
Dependencies are registered in layers, with lower-level dependencies (like Firebase instances) registered first, followed by data sources, repositories, use cases, and finally presentation layer components.

### 3. Separation of Concerns
The service locator is separate from the main application file, keeping the main file clean and focused on application setup.

### 4. BLoC Integration
BLoC providers are set up separately to integrate with the dependency injection system while still allowing for proper BLoC initialization with their dependencies.

### 5. Extensibility
The system is designed to be easily extensible, allowing for new dependencies to be added as needed.

## Verification

To verify this step is complete:

1. The service locator file should exist in `lib/core/di/`
2. All dependencies should be properly registered with appropriate lifecycles
3. The main application should properly initialize the dependency injection system
4. BLoC providers should be correctly set up and integrated
5. Dependencies should be resolvable throughout the application

## Code Quality Checks

1. All dependencies should be registered with clear, descriptive names
2. The registration order should follow dependency hierarchy
3. Error handling should be considered for dependency initialization
4. The code should be organized and easy to maintain
5. Comments should explain complex registration logic

### **Implementation Checklist for Step 11: Setup Dependency Injection**

[ ] Choose and add a dependency injection package (e.g., `get_it`, `injectable`) to `pubspec.yaml`
[ ] Create a service locator or dependency injection container (e.g., `lib/di/service_locator.dart`)
[ ] Register repositories (Product, Cart, User) as singletons or factories
[ ] Register use cases (GetAllProducts, CreateProduct, AddItemToCart, etc.) as factories
[ ] Register BLoCs (ProductBloc, CartBloc, AIInteractionBloc) as factories, injecting their dependencies
[ ] Register the `NaturalLanguageProcessor` and `AIActionExecutor` as singletons or factories
[ ] Create an initialization function to set up all dependencies
[ ] Integrate the DI container with the app’s entry point (e.g., in `main.dart` before `runApp`)
[ ] Update UI components to retrieve BLoCs from the DI container (instead of manual construction)
[ ] Add comprehensive error handling for dependency resolution
[ ] Write unit tests to verify dependencies are registered and resolved correctly
[ ] Document the dependency graph and registration process
[ ] Implement environment-specific configurations (e.g., dev, prod) if applicable

## Next Steps

After completing this step, we can move on to implementing the testing framework which will allow us to verify that our application works correctly.