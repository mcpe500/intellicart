// lib/screens/seller/seller_product_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:intellicart/models/product.dart';
import 'package:intellicart/presentation/bloc/seller/seller_product_bloc.dart';
import 'package:intellicart/presentation/screens/seller/seller_add_edit_product_page.dart';
=======

import 'package:intellicart_frontend/presentation/bloc/seller/seller_product_bloc.dart';
import 'package:intellicart_frontend/presentation/screens/seller/seller_add_edit_product_page.dart';
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

class SellerProductListPage extends StatelessWidget {
  const SellerProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF181411);
    const Color accentColor = Color(0xFFD97706);

    return BlocProvider(
      create: (context) => SellerProductBloc()..add(LoadSellerProducts()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryTextColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'My Product Listings',
            style: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<SellerProductBloc, SellerProductState>(
          builder: (context, state) {
            if (state is SellerProductLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SellerProductLoaded) {
              if (state.products.isEmpty) {
                return const Center(child: Text('No products found. Add one!'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
<<<<<<< HEAD
                      leading: Image.network(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            const Icon(Icons.image_not_supported, size: 50),
=======
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl ?? 'https://via.placeholder.com/50',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (ctx, err, stack) =>
                              const Icon(Icons.image_not_supported, size: 50),
                        ),
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
                      ),
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(product.price),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: accentColor),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: BlocProvider.of<SellerProductBloc>(context),
                                    child: SellerAddEditProductPage(product: product),
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              // Dispatch delete event
                              context.read<SellerProductBloc>().add(DeleteSellerProduct(product));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            if (state is SellerProductError) {
              return const Center(child: Text('Failed to load products.'));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to Add/Edit page without a product
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<SellerProductBloc>(context),
                  child: const SellerAddEditProductPage(),
                ),
              ),
            );
          },
          backgroundColor: accentColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
