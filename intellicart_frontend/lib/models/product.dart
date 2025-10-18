// lib/models/product.dart
import 'package:intellicart_frontend/models/review.dart'; // Import the new Review model

class Product {
  final String name;
  final String description;
  final String price;
  final String? originalPrice; // For the strikethrough price, can be null
  final String imageUrl;
  final List<Review> reviews; // A list of reviews for the product

  Product({
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice, // Make it optional
    required this.imageUrl,
    required this.reviews, // Make it required
  });
}
