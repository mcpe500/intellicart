import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart_frontend/bloc/cart/cart_bloc.dart';
import 'package:intellicart_frontend/bloc/product/product_bloc.dart';
import 'package:intellicart_frontend/widgets/common/custom_app_bar.dart';
import 'package:intellicart_frontend/widgets/common/product_card.dart';
import 'package:intellicart_frontend/data/models/cart_item.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const LoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Products',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (value) {
                      context.read<ProductBloc>().add(SearchProducts(value));
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip('All'),
                        _buildCategoryChip('Electronics'),
                        _buildCategoryChip('Clothing'),
                        _buildCategoryChip('Food'),
                        _buildCategoryChip('Books'),
                        _buildCategoryChip('Home'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductStateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductStateLoaded) {
                    if (state.products.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(category),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
          if (category == 'All') {
            context.read<ProductBloc>().add(const LoadProducts());
          } else {
            context.read<ProductBloc>().add(FilterProducts({'category': category}));
          }
        },
      ),
    );
  }
}
