import 'package:flutter/material.dart';
import 'package:intellicart/screens/ecommerce_home_page.dart'; // Adjust the import path as needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
        fontFamily: 'Plus Jakarta Sans', // Apply the font family if you've added it
      ),
      home: const EcommerceHomePage(), // Use your new modular page here
    );
  }
}