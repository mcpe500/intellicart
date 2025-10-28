import 'package:flutter/material.dart';
import 'package:intellicart/domain/entities/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product? product;

  const ProductDetailPage({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
      ),
      body: product != null
          ? ListView(
              children: [
                Image.network(
                  product!.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product!.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product!.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '\$${product!.price}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (product!.originalPrice != null)
                        Text(
                          '\$${product!.originalPrice}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: Text('No product data available'),
            ),
    );
  }
}