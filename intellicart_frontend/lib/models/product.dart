// lib/models/product.dart
import 'package:intellicart_frontend/models/review.dart'; // Import the new Review model

class Product {
  final String id;
  final String name;
  final String description;
  final String price;
  final String? originalPrice; // For the strikethrough price, can be null
  final String imageUrl;
  final List<Review> reviews; // A list of reviews for the product

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice, // Make it optional
    required this.imageUrl,
    required this.reviews, // Make it required
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<Review> reviews = [];
    if (json['reviews'] != null) {
      reviews = (json['reviews'] as List)
          .map((reviewJson) => Review.fromJson(reviewJson))
          .toList();
    }

    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      originalPrice: json['originalPrice'],
      imageUrl: json['imageUrl'] ?? '',
      reviews: reviews,
    );
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
}