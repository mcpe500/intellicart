import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intellicart/core/di/service_locator.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/cart/cart_bloc.dart';
import 'package:intellicart/presentation/bloc/user/user_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/bloc/auth/auth_bloc.dart';
import 'package:intellicart/presentation/ai/natural_language_processor.dart';
import 'package:intellicart/presentation/screens/home_screen.dart';
import 'package:intellicart/presentation/screens/login_screen.dart';
import 'package:intellicart/presentation/bloc/auth/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  await init(); // Initialize service locator
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            syncProducts: sl(),
          )..add(LoadProducts()),
        ),
        BlocProvider(
          create: (context) => CartBloc(
            getCartItems: sl(),
            addItemToCart: sl(),
            updateCartItem: sl(),
            removeItemFromCart: sl(),
            clearCart: sl(),
            getCartTotal: sl(),
          )..add(LoadCartItems()),
        ),
        BlocProvider(
          create: (context) => UserBloc(
            getCurrentUser: sl(),
            updateUser: sl(),
            signOut: sl(),
          )..add(LoadUser()),
        ),
        BlocProvider(
          create: (context) => AIInteractionBloc(
            processor: NaturalLanguageProcessor(),
            getAllProducts: sl(),
            addItemToCart: sl(),
            voiceService: sl(),
          ),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            getCurrentUser: sl(),
            updateUser: sl(),
            signOut: sl(),
          )..add(AppStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'Intellicart',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const HomeScreen();
            }
            if (state is Unauthenticated) {
              return const LoginScreen();
            }
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state is AuthError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}'),
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
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}