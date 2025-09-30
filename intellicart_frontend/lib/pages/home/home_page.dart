import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intellicart_frontend/bloc/cart/cart_bloc.dart';
import 'package:intellicart_frontend/bloc/product/product_bloc.dart';
import 'package:intellicart_frontend/data/models/cart_item.dart';
import 'package:intellicart_frontend/widgets/common/custom_app_bar.dart';
import 'package:intellicart_frontend/widgets/common/product_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'IntelliCart',
        showBackButton: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to IntelliCart',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductStateLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProductStateLoaded) {
                      if (state.products.isEmpty) {
                        return const Center(child: Text('No products available'));
                      }
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              // Navigate to product details
                            },
                            onAddToCart: () {
                              context.read<CartBloc>().add(
                                    AddToCart(
                                      CartItem(
                                        productId: product.id,
                                        productName: product.name,
                                        price: product.price,
                                        quantity: 1,
                                        imageUrl: product.imageUrl,
                                        createdAt: DateTime.now(),
                                      ),
                                    ),
                                  );
                            },
                          );
                        },
                      );
                    } else if (state is ProductStateError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const Center(child: Text('No products loaded'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/products');
              break;
            case 2:
              context.go('/cart');
              break;
            case 3:
              context.go('/profile');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}