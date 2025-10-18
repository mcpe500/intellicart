// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define colors from the HTML for consistency
    const Color primaryOrange = Color(0xFFF26C0D);

    return Scaffold(
      backgroundColor: primaryOrange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Section
            Container(
              width: 128,
              height: 128,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag, // A suitable Flutter equivalent for the SVG
                color: primaryOrange,
                size: 64.0,
              ),
            ),
            const SizedBox(height: 24.0),

            // Title and Subtitle
            const Text(
              'Intellicart',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Your smart retail advisor wrapped in one app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha((255 * 0.8).round()),
                ),
              ),
            ),
            const SizedBox(height: 64.0),

            // Loading Indicator Section
            SizedBox(
              width: 256, // Corresponds to w-64 in Tailwind
              child: Column(
                children: [
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withAlpha((255 * 0.2).round()),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
