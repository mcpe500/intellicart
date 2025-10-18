import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart_frontend/bloc/auth/auth_bloc.dart';
import 'package:intellicart_frontend/bloc/location/location_bloc.dart';
import 'package:intellicart_frontend/widgets/common/custom_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'John Doe',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'john.doe @example.com',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('My Location'),
                subtitle: BlocBuilder<LocationBloc, LocationState>(
                  builder: (context, state) {
                    if (state is LocationStateLoaded) {
                      return const Text('Location available');
                    } else if (state is LocationStateTracking) {
                      return const Text('Tracking location...');
                    } else if (state is LocationStateError) {
                      return Text(state.message);
                    }
                    return const Text('Location not available');
                  },
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.read<LocationBloc>().add(const GetCurrentLocation());
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Order History'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to order history
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Wishlist'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to wishlist
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Payment Methods'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to payment methods
                },
              ),
              const Divider(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                  },
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
