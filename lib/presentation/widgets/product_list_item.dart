import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_bloc.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_event.dart';

/// Widget that displays a single product in the list.
class ProductListItem extends StatelessWidget {
  final Product product;

  const ProductListItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: product.imageUrl.isNotEmpty
            ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.image),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${product.price.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit product screen
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Delete product
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                // AI-enhanced add to cart
                context.read<AIInteractionBloc>().add(
                      ProcessNaturalLanguageCommand(
                        'Add ${product.name} to my cart',
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}