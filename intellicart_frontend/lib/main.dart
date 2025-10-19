// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart_frontend/data/repositories/app_repository_impl.dart';
import 'package:intellicart_frontend/presentation/bloc/app_mode_bloc.dart';
import 'package:intellicart_frontend/presentation/screens/buyer/ecommerce_home_page.dart';
import 'package:intellicart_frontend/presentation/screens/core/login_page.dart';
import 'package:intellicart_frontend/presentation/screens/core/splash_screen.dart';
import 'package:intellicart_frontend/presentation/screens/seller/seller_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider(
      create: (context) => AppModeBloc(repository: AppRepositoryImpl())..add(LoadAppMode()),
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate loading tasks
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

    // After initialization, use the AppModeBloc to decide which page to show
    return BlocBuilder<AppModeBloc, AppModeState>(
      builder: (context, state) {
        if (state.mode == AppMode.seller) {
          return const SellerDashboardPage();
        }
        // Default to Buyer mode
        return const EcommerceHomePage(); // Will load products internally
      },
    );
  }
}
