// lib/screens/seller/seller_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/app_mode_bloc.dart';
import 'package:intellicart/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:intellicart/presentation/screens/auth_wrapper.dart';
import 'package:intellicart/presentation/screens/buyer/ecommerce_home_page.dart';
import 'package:intellicart/presentation/screens/seller/seller_order_management_page.dart';
import 'package:intellicart/presentation/screens/seller/seller_product_list_page.dart';
import 'package:intellicart/data/datasources/auth/auth_api_service.dart';

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF181411);
    const Color accentColor = Color(0xFFD97706);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2F0), // lightGreyBackground
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Seller Dashboard',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: accentColor),
            tooltip: 'Switch to Buyer Mode',
            onPressed: () {
              // Dispatch logout event to the AuthBloc
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              // Reset app mode to buyer
              context.read<AppModeBloc>().add(const SetAppMode(AppMode.buyer));
              // Navigate back to the entry point, which will be handled by AuthWrapper
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthWrapper()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.list_alt,
            title: 'Product Listings',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SellerProductListPage()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'Order Management',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SellerOrderManagementPage()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.bar_chart,
            title: 'Sales Analytics',
            color: Colors.orange,
            onTap: () {
              // Placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analytics coming soon!')),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.store_outlined,
            title: 'Storefront Setup',
            color: Colors.purple,
            onTap: () {
              // Placeholder for Vendor Registration/Setup
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Store setup coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181411),
              ),
            ),
          ],
        ),
      ),
    );
  }
}