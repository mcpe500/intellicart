// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:intellicart/data/datasources/api_service.dart';
import 'package:intellicart/data/repositories/app_repository_impl.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/presentation/bloc/app_mode_bloc.dart';
import 'package:intellicart/presentation/screens/buyer/ecommerce_home_page.dart';
import 'package:intellicart/presentation/screens/core/splash_screen.dart';
import 'package:intellicart/presentation/screens/seller/seller_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider(
      create: (context) => AppModeBloc(repository: AppRepositoryImpl())..add(LoadAppMode()),
=======
import 'package:intellicart_frontend/data/repositories/app_repository_impl.dart';
import 'package:intellicart_frontend/bloc/auth/auth_bloc.dart';
import 'package:intellicart_frontend/bloc/cart/cart_bloc.dart';
import 'package:intellicart_frontend/bloc/wishlist/wishlist_bloc.dart';
import 'package:intellicart_frontend/data/repositories/cart_repository.dart';
import 'package:intellicart_frontend/data/repositories/wishlist_repository.dart';
import 'package:intellicart_frontend/utils/service_locator.dart';

import 'package:intellicart_frontend/presentation/bloc/app_mode_bloc.dart';
import 'package:intellicart_frontend/presentation/bloc/buyer/review_bloc.dart';
import 'package:intellicart_frontend/presentation/screens/buyer/ecommerce_home_page.dart';
import 'package:intellicart_frontend/presentation/screens/core/login_page.dart';
import 'package:intellicart_frontend/presentation/screens/core/splash_screen.dart';
import 'package:intellicart_frontend/presentation/screens/seller/seller_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppModeBloc(repository: AppRepositoryImpl(apiService: serviceLocator.apiService))..add(LoadAppMode()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(apiService: serviceLocator.apiService),
        ),
        BlocProvider(
          create: (context) => CartBloc(
            cartRepository: CartRepositoryImpl()
          ),
        ),
        BlocProvider(
          create: (context) => WishlistBloc(
            wishlistRepository: WishlistRepositoryImpl()
          ),
        ),
        // Add ReviewBloc with the shared ApiService
        BlocProvider(
          create: (context) => ReviewBloc(apiService: serviceLocator.apiService),
        ),

      ],
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intellicart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
<<<<<<< HEAD
  List<Product> _products = [];
=======
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
<<<<<<< HEAD
    // 1. Fetch products from the API Service (which uses the mock backend)
    final apiService = ApiService();
    final productsFromApi = await apiService.getProducts();

    // 2. Save fetched products to the local repository
    final repository = AppRepositoryImpl();
    await repository.insertProducts(productsFromApi);

    // 3. Load products from the repository to be used by the UI
    _products = await repository.getProducts();

    // Simulate other loading tasks
=======
    // Simulate loading tasks
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

<<<<<<< HEAD
    // After initialization, use the AppModeBloc to decide which page to show
    return BlocBuilder<AppModeBloc, AppModeState>(
      builder: (context, state) {
        if (state.mode == AppMode.seller) {
          return const SellerDashboardPage();
        }
        // Default to Buyer mode
        return EcommerceHomePage(products: _products);
      },
    );
  }
}
=======
    // First check authentication state
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthStateAuthenticated) {
          // User is authenticated, show main app based on app mode
          return BlocBuilder<AppModeBloc, AppModeState>(
            builder: (context, state) {
              if (state.mode == AppMode.seller) {
                return const SellerDashboardPage();
              }
              // Default to Buyer mode
              return const EcommerceHomePage(); // Will load products internally
            },
          );
        } else if (authState is AuthStateUnauthenticated || authState is AuthStateInitial) {
          // User is not authenticated, show login page
          return const LoginPage();
        } else if (authState is AuthStateLoading) {
          // Still checking auth status, show loading
          return const SplashScreen();
        } else if (authState is AuthStateError) {
          // There was an error, show login page
          return const LoginPage();
        }
        
        // Default to login page
        return const LoginPage();
      },
    );
  }
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
