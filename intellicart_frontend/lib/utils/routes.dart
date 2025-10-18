import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intellicart_frontend/pages/home/home_page.dart';
import 'package:intellicart_frontend/pages/products/products_page.dart';
import 'package:intellicart_frontend/pages/cart/cart_page.dart';
import 'package:intellicart_frontend/pages/profile/profile_page.dart';
import 'package:intellicart_frontend/pages/settings/settings_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
