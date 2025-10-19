// lib/presentation/screens/core/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// --- REMOVED UNUSED IMPORTS ---
// import 'package:intellicart_frontend/data/datasources/api_service.dart';
// import 'package:intellicart_frontend/models/user.dart';
// import 'package:intellicart_frontend/main.dart'; // For AppInitializer

// --- ADDED BLOC IMPORT ---
import 'package:intellicart_frontend/bloc/auth/auth_bloc.dart';
import 'package:intellicart_frontend/presentation/bloc/app_mode_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  // --- REMOVED STATE VARS NOW HANDLED BY BLOC ---
  // bool _isLoading = false;
  // String _errorMessage = '';
  // final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // --- SIMPLIFIED SUBMIT TO ONLY DISPATCH EVENTS ---
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // The BLoC will handle setting loading state,
    // calling the API, saving the token, and emitting the final state.
    if (_isLogin) {
      context.read<AuthBloc>().add(LoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ));
    } else {
      context.read<AuthBloc>().add(RegisterRequested(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF181411);
    const Color accentColor = Color(0xFFD97706);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // No back button on the root login page
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: primaryTextColor),
        //   onPressed: () => Navigator.pop(context),
        // ),
        automaticallyImplyLeading: false,
        title: Text(
          _isLogin ? 'Welcome Back' : 'Create Account',
          style: const TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // --- WRAPPED BODY IN BLOCCONSUMER ---
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // 1. Listen for errors to show a SnackBar
          if (state is AuthStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          
          // 2. Listen for success to set AppMode (this is still useful)
          if (state is AuthStateAuthenticated) {
             // We can check the user role from the API service if needed,
             // but for now, we just rely on the AppInitializer
             // to handle the navigation.
             // We can also optimistically set the app mode here.
             // For now, AppInitializer handles this navigation.
          }
        },
        builder: (context, state) {
          // 3. Determine loading state from the BLoC
          final bool isLoading = state is AuthStateLoading;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or app branding
                  Icon(
                    Icons.shopping_bag,
                    size: 80,
                    color: accentColor,
                  ),
                  const SizedBox(height: 32),

                  if (!_isLogin) ...[
                    // Name field for registration
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
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
                  const SizedBox(height: 16),

                  // Removed error message text, SnackBar handles it

                  const SizedBox(height: 16),

                  // Login/Register button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // 4. Use isLoading to disable button
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // 5. Show loading indicator
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isLogin ? 'Login' : 'Register',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Toggle between login and register
                  TextButton(
                    onPressed: isLoading ? null : () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'New user? Register here'
                          : 'Already have an account? Login',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
