# 14 - Implement Authentication Flow

## Overview
This step involves implementing the authentication flow for the Intellicart application using Firebase Authentication. We'll create authentication BLoC components, UI screens for login/signup, and integrate authentication with the existing application structure.

## Implementation Details

### 1. Create Authentication Event Classes

Create `lib/presentation/bloc/auth/auth_event.dart`:

```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignUpRequested(this.email, this.password, this.name);

  @override
  List<Object?> get props => [email, password, name];
}

class LogoutRequested extends AuthEvent {}
```

### 2. Create Authentication State Classes

Create `lib/presentation/bloc/auth/auth_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### 3. Create Authentication Use Cases

Create `lib/domain/usecases/auth/login_user.dart`:

```dart
import 'package:intellicart/domain/repositories/user_repository.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';

class LoginUser {
  final UserRepository repository;

  LoginUser(this.repository);

  Future<void> call(String email, String password) async {
    try {
      // In a real implementation, this would involve Firebase Auth
      // For now, we'll just simulate the process
      if (email.isEmpty || password.isEmpty) {
        throw AuthenticationException('Email and password cannot be empty');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthenticationException('Login failed: $e');
    }
  }
}
```

Create `lib/domain/usecases/auth/signup_user.dart`:

```dart
import 'package:intellicart/domain/repositories/user_repository.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';

class SignupUser {
  final UserRepository repository;

  SignupUser(this.repository);

  Future<void> call(String email, String password, String name) async {
    try {
      // In a real implementation, this would involve Firebase Auth
      // For now, we'll just simulate the process
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw AuthenticationException('Email, password, and name cannot be empty');
      }
      if (password.length < 6) {
        throw AuthenticationException('Password must be at least 6 characters long');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthenticationException('Signup failed: $e');
    }
  }
}
```

Create `lib/domain/usecases/auth/logout_user.dart`:

```dart
import 'package:intellicart/domain/repositories/user_repository.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';

class LogoutUser {
  final UserRepository repository;

  LogoutUser(this.repository);

  Future<void> call() async {
    try {
      await repository.signOut();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthenticationException('Logout failed: $e');
    }
  }
}
```

### 4. Create Authentication BLoC

Create `lib/presentation/bloc/auth/auth_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/usecases/auth/login_user.dart';
import 'package:intellicart/domain/usecases/auth/signup_user.dart';
import 'package:intellicart/domain/usecases/auth/logout_user.dart';
import 'package:intellicart/domain/usecases/get_current_user.dart';
import 'package:intellicart/presentation/bloc/auth/auth_event.dart';
import 'package:intellicart/presentation/bloc/auth/auth_state.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final SignupUser signupUser;
  final LogoutUser logoutUser;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.loginUser,
    required this.signupUser,
    required this.logoutUser,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await getCurrentUser();
      emit(Authenticated(user));
    } on UserNotAuthenticatedException {
      emit(Unauthenticated());
    } on AppException catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthError('Unexpected error: $e'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await loginUser(event.email, event.password);
      final user = await getCurrentUser();
      emit(Authenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthError('Unexpected error: $e'));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await signupUser(event.email, event.password, event.name);
      final user = await getCurrentUser();
      emit(Authenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthError('Unexpected error: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await logoutUser();
      emit(Unauthenticated());
    } on AppException catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthError('Unexpected error: $e'));
    }
  }
}
```

### 5. Create Get Current User Use Case

Create `lib/domain/usecases/get_current_user.dart`:

```dart
import 'package:intellicart/domain/entities/user.dart';
import 'package:intellicart/domain/repositories/user_repository.dart';

class GetCurrentUser {
  final UserRepository repository;

  GetCurrentUser(this.repository);

  Future<User> call() async {
    return await repository.getCurrentUser();
  }
}
```

### 6. Update Service Locator with Authentication Dependencies

Update `lib/core/di/service_locator.dart`:

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
import 'package:intellicart/domain/usecases/get_current_user.dart';
import 'package:intellicart/domain/usecases/auth/login_user.dart';
import 'package:intellicart/domain/usecases/auth/signup_user.dart';
import 'package:intellicart/domain/usecases/auth/logout_user.dart';
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

### 7. Create Authentication UI Components

Create `lib/presentation/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/auth/auth_bloc.dart';
import 'package:intellicart/presentation/bloc/auth/auth_event.dart';
import 'package:intellicart/presentation/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              _emailController.text.trim(),
              _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Create `lib/presentation/screens/signup_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/auth/auth_bloc.dart';
import 'package:intellicart/presentation/bloc/auth/auth_event.dart';
import 'package:intellicart/presentation/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      context.read<AuthBloc>().add(
            SignUpRequested(
              _emailController.text.trim(),
              _passwordController.text,
              _nameController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signup,
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 8. Update Main Application with Authentication Flow

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/di/service_locator.dart' as di;
import 'package:intellicart/presentation/bloc/bloc_providers.dart';
import 'package:intellicart/presentation/bloc/auth/auth_bloc.dart';
import 'package:intellicart/presentation/bloc/auth/auth_event.dart';
import 'package:intellicart/presentation/bloc/auth/auth_state.dart';
import 'package:intellicart/presentation/screens/login_screen.dart';
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
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is Authenticated) {
              return const HomeScreen();
            }
            if (state is Unauthenticated) {
              return const LoginScreen();
            }
            if (state is AuthError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AppStarted());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            // Initial state - check authentication status
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AuthBloc>().add(AppStarted());
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
```

### 9. Update BLoC Providers with Authentication BLoC

Update `lib/presentation/bloc/bloc_providers.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/di/service_locator.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/cart/cart_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/bloc/auth/auth_bloc.dart';

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
        BlocProvider(
          create: (context) => AuthBloc(
            loginUser: sl(),
            signupUser: sl(),
            logoutUser: sl(),
            getCurrentUser: sl(),
          ),
        ),
      ],
      child: child,
    );
  }
}
```

## Design Considerations

### 1. Firebase Authentication Integration
In a real implementation, we would integrate with Firebase Authentication for actual user management. For this implementation, we're simulating the process.

### 2. Authentication State Management
The application properly manages authentication states (authenticated, unauthenticated, loading, error) and transitions between them.

### 3. User Experience
The authentication flow provides a good user experience with proper form validation and error handling.

### 4. Security
Password fields are properly obscured, and password strength is validated.

### 5. Navigation
The application properly navigates between authentication and main application screens based on authentication state.

## Verification

To verify this step is complete:

1. All authentication-related files should exist in the appropriate directories
2. Authentication BLoC should properly manage authentication states
3. Login and signup screens should be functional with proper validation
4. Main application should properly route based on authentication state
5. Authentication use cases should be properly implemented
6. Service locator should include authentication dependencies

## Code Quality Checks

1. All authentication components should have proper documentation comments
2. Form validation should be comprehensive and user-friendly
3. Error handling should be consistent with the rest of the application
4. Navigation should be smooth and logical
5. Code should follow Flutter and Dart best practices

## Next Steps

After completing this step, we can move on to adding voice interaction capabilities to our application.