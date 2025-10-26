// lib/presentation/screens/core/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/models/user.dart';
import 'package:intellicart/presentation/bloc/app_mode_bloc.dart';
import 'package:intellicart/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:intellicart/presentation/screens/auth_wrapper.dart';

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
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_isLogin) {
      // Login
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          _emailController.text.trim(),
          _passwordController.text,
        ),
      );
    } else {
      // Register
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
          'buyer', // Default to buyer role
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF181411);
    const Color accentColor = Color(0xFFD97706);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Set app mode based on user role
          if (state.user.role == 'seller') {
            context.read<AppModeBloc>().add(const SetAppMode(AppMode.seller));
          } else {
            context.read<AppModeBloc>().add(const SetAppMode(AppMode.buyer));
          }
          
          // Navigate to AuthWrapper which will show the appropriate main screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
            (route) => false,
          );
        } else if (state is AuthError) {
          setState(() {
            _errorMessage = state.message;
            _isLoading = false;
          });
        } else if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: primaryTextColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _isLogin ? 'Welcome Back' : 'Create Account',
              style: const TextStyle(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
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
                  
                  // Error message
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Login/Register button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
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
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _errorMessage = '';
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
          ),
        );
      },
    );
  }
}