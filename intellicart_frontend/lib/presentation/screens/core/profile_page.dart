// lib/presentation/screens/core/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart_frontend/main.dart'; // For AppInitializer
import 'package:intellicart_frontend/presentation/bloc/app_mode_bloc.dart';
import 'package:intellicart_frontend/presentation/screens/core/login_page.dart'; // For LoginPage
import 'package:intellicart_frontend/presentation/screens/seller/seller_dashboard_page.dart'; // <-- ADD THIS IMPORT
import 'package:intellicart_frontend/data/datasources/api_service.dart';
import 'package:intellicart_frontend/models/user.dart';
import 'package:intellicart_frontend/bloc/auth/auth_bloc.dart';
import 'package:intellicart_frontend/data/repositories/auth_repository.dart';
import 'package:intellicart_frontend/utils/service_locator.dart';
import 'package:intellicart_frontend/presentation/screens/core/personal_information_page.dart'; // Add import for personal info page

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _getCurrentUserWithToken();
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<User?> _getCurrentUserWithToken() async {
    final apiService = serviceLocator.apiService;
    final token = await serviceLocator.authRepository.getAuthToken();
    
    if (token != null) {
      apiService.setToken(token);
      return await apiService.getCurrentUser();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadUserProfile(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info Section
                        if (_currentUser != null) ...[
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${_currentUser!.name}',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Email: ${_currentUser!.email}'),
                                  if (_currentUser!.phoneNumber != null)
                                    Text('Phone: ${_currentUser!.phoneNumber}'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Mode Switching Options
                        Text(
                          'Switch Mode',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildProfileOption(
                          icon: Icons.storefront,
                          title: 'Seller Dashboard',
                          subtitle: 'Manage your store and products',
                          onTap: () {
                            // Update app mode to seller
                            context.read<AppModeBloc>().add(const SetAppMode(AppMode.seller));
                            // Navigate to seller dashboard
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SellerDashboardPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildProfileOption(
                          icon: Icons.shopping_cart,
                          title: 'Buyer Mode',
                          subtitle: 'Browse and purchase products',
                          onTap: () {
                            // Update app mode to buyer
                            context.read<AppModeBloc>().add(const SetAppMode(AppMode.buyer));
                            // Navigate to buyer home
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const AppInitializer()),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Profile Management Options
                        Text(
                          'Profile Management',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildProfileOption(
                          icon: Icons.account_circle,
                          title: 'Personal Information',
                          subtitle: 'Update your personal details',
                          onTap: () {
                            // Navigate to personal information page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PersonalInformationPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildProfileOption(
                          icon: Icons.store,
                          title: 'Store Settings',
                          subtitle: 'Manage your store information',
                          onTap: () {
                            // Update app mode to seller
                            context.read<AppModeBloc>().add(const SetAppMode(AppMode.seller));
                            // Navigate to seller dashboard
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SellerDashboardPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildProfileOption(
                          icon: Icons.shopping_bag,
                          title: 'Buyer Preferences',
                          subtitle: 'Manage your shopping preferences',
                          onTap: () {
                            // Update app mode to buyer
                            context.read<AppModeBloc>().add(const SetAppMode(AppMode.buyer));
                            // Navigate to buyer home
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const AppInitializer()),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Account Actions
                        Text(
                          'Account Actions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildProfileOption(
                          icon: Icons.logout,
                          title: 'Logout',
                          subtitle: 'Sign out of your account',
                          onTap: () {
                            // Dispatch logout event
                            context.read<AuthBloc>().add(const LogoutRequested());
                            // Navigate to login page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildProfileOption(
                          icon: Icons.delete,
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          onTap: () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Account'),
                                  content: const Text(
                                      'Are you sure you want to delete your account? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Implement account deletion
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Account deletion not implemented yet')),
                                        );
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 36),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}