// lib/screens/wishlist_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/bloc/wishlist/wishlist_bloc.dart';
import 'package:intellicart_frontend/bloc/cart/cart_bloc.dart';
import 'package:intellicart_frontend/data/models/wishlist_item.dart';
import 'package:intellicart_frontend/data/models/cart_item.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Wishlist'),
            centerTitle: true,
          ),
          body: state is WishlistLoading
              ? const Center(child: CircularProgressIndicator())
              : state is WishlistLoaded
                  ? state.wishlistItems.isEmpty
                      ? _buildEmptyWishlist(context)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: state.wishlistItems.length,
                          itemBuilder: (context, index) {
                            final item = state.wishlistItems[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    item.productImageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: const Icon(Icons.image_not_supported),
                                        ),
                                  ),
                                ),
                                title: Text(
                                  item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(item.productPrice),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.shopping_cart),
                                      onPressed: () {
                                        // Add to cart
                                        final cartItem = CartItem(
                                          productId: item.productId,
                                          productName: item.productName,
                                          productDescription: item.productDescription,
                                          productPrice: item.productPrice,
                                          productOriginalPrice: item.productOriginalPrice,
                                          productImageUrl: item.productImageUrl,
                                          quantity: 1,
                                        );
                                        
                                        context.read<CartBloc>().add(AddToCart(cartItem));
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Added ${item.productName} to cart!'),
                                            backgroundColor: Theme.of(context).colorScheme.secondary,
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        // Remove from wishlist
                                        context.read<WishlistBloc>().add(
                                          RemoveFromWishlist(item.productId),
                                        );
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Removed ${item.productName} from wishlist!'),
                                            backgroundColor: Theme.of(context).colorScheme.secondary,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                  : state is WishlistError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error: ${state.message}'),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<WishlistBloc>().add(LoadWishlist());
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : const Center(child: Text('Unknown state')),
        );
      },
    );
  }

  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your wishlist is empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items to your wishlist',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to home page or product listing
              Navigator.pop(context);
            },
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }
}