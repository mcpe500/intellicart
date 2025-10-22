// lib/presentation/screens/core/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:intellicart/main.dart'; // For AppInitializer
import 'package:intellicart/presentation/bloc/app_mode_bloc.dart';
import 'package:intellicart/presentation/screens/core/login_page.dart'; // For LoginPage
import 'package:intellicart/presentation/screens/seller/seller_dashboard_page.dart'; // <-- ADD THIS IMPORT

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
=======
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

  // Helper method to get user with proper token handling and retries
  Future<User?> _getCurrentUserWithToken() async {
    // Use the shared ApiService instance from the service locator
    final apiService = serviceLocator.apiService;
    
    // First, make sure the token is loaded in the shared service
    final token = await serviceLocator.authRepository.getAuthToken();
    if (token != null && token.isNotEmpty) {
      apiService.setToken(token);
    }
    
    // Ensure the service is ready before making the request
    await apiService.ensureInitialized();
    
    return await apiService.getCurrentUser();
  }

  @override
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
  Widget build(BuildContext context) {
    // Define colors from the HTML for consistency
    const Color pageBgColor = Color(0xFFFFFAF0);
    const Color primaryTextColor = Color(0xFF4A2511);
    const Color accentColor = Color(0xFFD97706);
    const Color accentColorBright = Color(0xFFFFA500);
    const Color iconBgColor = Color(0xFFFFF7ED);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () {
            // If this page is part of the main navigation, you might not need a back button.
            // But if it's pushed on top, this is how you'd go back.
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: primaryTextColor),
            onPressed: () {},
          ),
        ],
      ),
<<<<<<< HEAD
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: accentColorBright,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuA56SWfDWVeNbwHLebF80iyl1g37Jn0frJ7zYWzJiJCM1kR29OGexdUdHeROcIyqrfBPXYSf8QxTqXKqBufi7WJwie0BGfACBAof8kUjd7IgFBIJNGAc7UF2GpXAG4_c--c7dvDpJvw-fxmPtIgjCPRW0OBSa6Tsqcf5r06tnEyrAVrJGqUtzvV9nEZiCn6jGEU77Gk7h1pMGgGxu08ZSfXCOxq91F_6CGeUb5IYvEXjzS2aA73krJfY3KirhaxWj0DgZTVQH5To-P9',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Olivia Chen',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 16,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- MODIFICATION: ADDED SELLER MODE BUTTON ---
              _buildProfileOption(
                icon: Icons.storefront_outlined, // New Icon
                title: 'Switch to Seller Mode', // New Title
                iconBgColor: iconBgColor,
                primaryTextColor: primaryTextColor,
                accentColor: accentColor,
                onTap: () {
                  // Dispatch event to change mode
                  context.read<AppModeBloc>().add(const SetAppMode(AppMode.seller));
                  // Navigate and replace the current screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SellerDashboardPage()),
                    (route) => false,
                  );
                },
              ),
              // --- END MODIFICATION ---

              // --- DEMO: ADD BUTTON TO SWITCH BACK TO BUYER MODE ---
              _buildProfileOption(
                icon: Icons.shopping_bag_outlined, // New Icon
                title: 'Switch to Buyer Mode', // New Title
                iconBgColor: iconBgColor,
                primaryTextColor: primaryTextColor,
                accentColor: accentColor,
                onTap: () {
                  // Dispatch event to change mode back to buyer
                  context.read<AppModeBloc>().add(const SetAppMode(AppMode.buyer));
                  // Navigate and replace the current screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AppInitializer()),
                    (route) => false,
                  );
                },
              ),
              // --- END DEMO MODIFICATION ---

              // Profile Options List
              _buildProfileOption(
                icon: Icons.person_outline,
                title: 'Personal Information',
                iconBgColor: iconBgColor,
                primaryTextColor: primaryTextColor,
                accentColor: accentColor,
              ),
              _buildProfileOption(
                icon: Icons.shopping_cart_outlined,
                title: 'My Orders',
                iconBgColor: iconBgColor,
                primaryTextColor: primaryTextColor,
                accentColor: accentColor,
              ),
              _buildProfileOption(
                icon: Icons.local_shipping_outlined,
                title: 'Track Delivery',
                iconBgColor: iconBgColor,
                primaryTextColor: primaryTextColor,
                accentColor: accentColor,
              ),
              _buildProfileOption(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                iconBgColor: iconBgColor,
                primaryTextColor: primaryTextColor,
                accentColor: accentColor,
              ),
              _buildProfileOption(
                icon: Icons.home_outlined,
                title: 'Addresses',
                iconBgColor: iconBgColor,
                primaryTextColor: primaryTextColor,
                accentColor: accentColor,
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'Help & Support',
                iconBgColor: iconBgColor,
                primaryTextColor: primaryTextColor,
                accentColor: accentColor,
              ),

              const SizedBox(height: 40),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Dispatch event to change mode back to buyer
                    context.read<AppModeBloc>().add(const SetAppMode(AppMode.buyer));
                    // Navigate and replace the current screen with the login page
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColorBright,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
=======
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: const BoxDecoration(
                                  color: accentColorBright,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: _currentUser != null
                                      ? CircleAvatar(
                                          radius: 60,
                                          backgroundColor: Colors.grey[200],
                                          child: CircleAvatar(
                                            radius: 56,
                                            backgroundColor: Colors.white,
                                            child: Text(
                                              _currentUser!.name.isNotEmpty
                                                  ? _currentUser!.name.substring(0, 1).toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: primaryTextColor,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 120,
                                          height: 120,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _currentUser?.name ?? 'User',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentUser?.email ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _currentUser?.role?.toUpperCase() ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // --- MODIFICATION: ADDED SELLER MODE BUTTON ---
                        _buildProfileOption(
                          icon: Icons.storefront_outlined, // New Icon
                          title: 'Switch to Seller Mode', // New Title
                          iconBgColor: iconBgColor,
                          primaryTextColor: primaryTextColor,
                          accentColor: accentColor,
                          onTap: () {
                            // Dispatch event to change mode
                            context.read<AppModeBloc>().add(const SetAppMode(AppMode.seller));
                            // Navigate and replace the current screen
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const SellerDashboardPage()),
                              (route) => false,
                            );
                          },
                        ),
                        // --- END MODIFICATION ---

                        // --- DEMO: ADD BUTTON TO SWITCH BACK TO BUYER MODE ---
                        _buildProfileOption(
                          icon: Icons.shopping_bag_outlined, // New Icon
                          title: 'Switch to Buyer Mode', // New Title
                          iconBgColor: iconBgColor,
                          primaryTextColor: primaryTextColor,
                          accentColor: accentColor,
                          onTap: () {
                            // Dispatch event to change mode back to buyer
                            context.read<AppModeBloc>().add(const SetAppMode(AppMode.buyer));
                            // Navigate and replace the current screen
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const AppInitializer()),
                              (route) => false,
                            );
                          },
                        ),
                        // --- END DEMO MODIFICATION ---

                        // Profile Options List
                        _buildProfileOption(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          iconBgColor: iconBgColor,
                          primaryTextColor: primaryTextColor,
                          accentColor: accentColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PersonalInformationPage(),
                              ),
                            );
                          },
                        ),
                        _buildProfileOption(
                          icon: Icons.shopping_cart_outlined,
                          title: 'My Orders',
                          iconBgColor: iconBgColor,
                          primaryTextColor: primaryTextColor,
                          accentColor: accentColor,
                        ),
                        _buildProfileOption(
                          icon: Icons.local_shipping_outlined,
                          title: 'Track Delivery',
                          iconBgColor: iconBgColor,
                          primaryTextColor: primaryTextColor,
                          accentColor: accentColor,
                        ),
                        _buildProfileOption(
                          icon: Icons.payment_outlined,
                          title: 'Payment Methods',
                          iconBgColor: iconBgColor,
                          primaryTextColor: primaryTextColor,
                          accentColor: accentColor,
                        ),
                        _buildProfileOption(
                          icon: Icons.home_outlined,
                          title: 'Addresses',
                          iconBgColor: iconBgColor,
                          primaryTextColor: primaryTextColor,
                          accentColor: accentColor,
                        ),
                        _buildProfileOption(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          iconBgColor: iconBgColor,
                          primaryTextColor: primaryTextColor,
                          accentColor: accentColor,
                        ),

                        const SizedBox(height: 40),

                        // Sign Out Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Dispatch event to change mode back to buyer
                              context.read<AuthBloc>().add(const LogoutRequested());
                              // Navigate and replace the current screen with the login page
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColorBright,
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
    );
  }

  // --- MODIFICATION: ADDED OPTIONAL onTap PARAMETER ---
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required Color iconBgColor,
    required Color primaryTextColor,
    required Color accentColor,
    VoidCallback? onTap, // Make onTap optional
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
<<<<<<< HEAD
              color: Colors.black.withOpacity(0.05),
=======
              color: Colors.black.withAlpha((255 * 0.05).round()),
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {}, // Use the provided onTap or an empty function
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(icon, color: primaryTextColor),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: accentColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
