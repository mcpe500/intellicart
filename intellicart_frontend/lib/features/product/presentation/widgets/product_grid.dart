// lib/features/product/presentation/widgets/product_grid.dart
import 'package:flutter/material.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/features/product/presentation/widgets/product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final Color accentColor;

  const ProductGrid({
    super.key,
    required this.products,
    this.accentColor = const Color(0xFFD95F18),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          accentColor: accentColor,
        );
      },
    );
  }
}