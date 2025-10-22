// lib/models/product.dart
<<<<<<< HEAD
import 'package:intellicart/models/review.dart'; // Import the new Review model

class Product {
=======
import 'package:intellicart_frontend/models/review.dart'; // Import the new Review model

class Product {
  final String id;
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
  final String name;
  final String description;
  final String price;
  final String? originalPrice; // For the strikethrough price, can be null
  final String imageUrl;
  final List<Review> reviews; // A list of reviews for the product

  Product({
<<<<<<< HEAD
=======
    required this.id,
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice, // Make it optional
    required this.imageUrl,
    required this.reviews, // Make it required
  });
<<<<<<< HEAD
=======

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: _parsePrice(json['price']),
      originalPrice: _parsePrice(json['originalPrice']),
      imageUrl: json['imageUrl'] ?? '',
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((review) => Review.fromJson(review))
              .toList() ?? [],
    );
  }

  // Helper method to parse price as either string or number
  static String _parsePrice(dynamic priceValue) {
    if (priceValue == null) return '';
    if (priceValue is String) return priceValue;
    if (priceValue is num) {
      // Format as price with $ and 2 decimal places
      return '\$${priceValue.toStringAsFixed(2)}';
    }
    return priceValue.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
}