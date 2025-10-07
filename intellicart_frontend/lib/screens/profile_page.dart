// lib/screens/profile_page.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
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
                  onPressed: () {},
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
    );
  }

  // Helper widget to build each option item, making the code cleaner and reusable
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required Color iconBgColor,
    required Color primaryTextColor,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
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
}