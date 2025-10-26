// lib/presentation/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/data/datasources/api_service.dart';
import 'package:intellicart/data/datasources/auth/auth_api_service.dart';
import 'package:intellicart/data/repositories/app_repository_impl.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/presentation/bloc/app_mode_bloc.dart';
import 'package:intellicart/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:intellicart/presentation/bloc/buyer/product_bloc.dart';
import 'package:intellicart/presentation/screens/buyer/ecommerce_home_page.dart';
import 'package:intellicart/presentation/screens/core/splash_screen.dart';
import 'package:intellicart/presentation/screens/seller/seller_dashboard_page.dart';
import 'package:intellicart/presentation/screens/core/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const MainApp();
          } else if (state is AuthUnauthenticated || state is AuthInitial) {
            return const LoginPage();
          } else if (state is AuthLoading) {
            return const SplashScreen();
          } else {
            // Handle error state by showing the login page
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductBloc(repository: context.read<AppRepositoryImpl>())
            ..add(LoadProducts()),
      child: BlocBuilder<AppModeBloc, AppModeState>(
        builder: (context, state) {
          if (state.mode == AppMode.seller) {
            return const SellerDashboardPage();
          }
          // Default to Buyer mode
          return const EcommerceHomePage();
        },
      ),
    );
  }
}
