// lib/features/product/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/review.dart';
import 'package:intellicart/presentation/screens/buyer/product_details_page.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Color accentColor;

  const ProductCard({
    Key? key,
    required this.product,
    this.accentColor = const Color(0xFFD95F18),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product.price,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  if (product.reviews.isNotEmpty) ...[
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        _buildStarRating(
                          _calculateAverageRating(product.reviews),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '(${product.reviews.length})',
                          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating ? Icons.star_half : Icons.star_border),
          color: const Color(0xFFFF9500),
          size: 12.0,
        );
      }),
    );
  }

  double _calculateAverageRating(List<dynamic> reviews) {
    if (reviews.isEmpty) return 0.0;
    
    num total = 0;
    for (dynamic review in reviews) {
      if (review is Map<String, dynamic>) {
        total += review['rating'] ?? 0;
      } else if (review is Review) {
        total += review.rating;
      }
    }
    
    return total / reviews.length;
  }
}