import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart_frontend/bloc/cart/cart_bloc.dart';
import 'package:intellicart_frontend/widgets/common/custom_app_bar.dart';
import 'package:intellicart_frontend/widgets/common/cart_item_card.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Shopping Cart',
      ),
      body: SafeArea(
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartStateLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CartStateLoaded) {
              if (state.items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              double totalPrice = state.items.fold(
                0.0,
                (sum, item) {
                  // Convert the string price to a double for calculation
                  String priceString = item.productPrice.toString();
                  // Remove any non-numeric characters except decimal point
                  final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '');
                  final price = double.tryParse(cleanPrice) ?? 0.0;
                  return sum + (price * item.quantity);
                },
              );
              
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return CartItemCard(
                          item: item,
                          onQuantityChanged: (quantity) {
                            context.read<CartBloc>().add(
                                  UpdateCartItem(
                                    item.copyWith(quantity: quantity),
                                  ),
                                );
                          },
                          onRemove: () {
                            context.read<CartBloc>().add(RemoveFromCart(item.id!));
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '\$${totalPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Checkout logic
                            },
                            child: const Text('Checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is CartStateError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Cart not loaded'));
          },
        ),
      ),
    );
  }
}
