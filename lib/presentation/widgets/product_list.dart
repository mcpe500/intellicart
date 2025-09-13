import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/product/product_state.dart';
import 'package:intellicart/presentation/widgets/product_list_item.dart';

/// Widget that displays a list of products.
class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductLoaded) {
          return ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              return ProductListItem(product: state.products[index]);
            },
          );
        }
        if (state is ProductError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('No products found'));
      },
    );
  }
}