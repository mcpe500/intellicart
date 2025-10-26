// lib/models/product.dart
import 'package:intellicart/models/review.dart'; // Import the new Review model

class Product {
  final String? id;  // String to handle both int and string IDs from backend
  final String name;
  final String description;
  final String price;
  final String? originalPrice; // For the strikethrough price, can be null
  final String imageUrl;
  final String? sellerId; // ID of the seller who added this product
  final List<Review> reviews; // A list of reviews for the product

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice, // Make it optional
    required this.imageUrl,
    this.sellerId, // Make it optional
    required this.reviews, // Make it required
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] is int) ? json['id'].toString() : json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int) ? json['price'].toString() : (json['price'] ?? ''),
      originalPrice: (json['originalPrice'] != null) 
        ? ((json['originalPrice'] is int) 
            ? json['originalPrice'].toString() 
            : json['originalPrice'])
        : null,
      imageUrl: json['imageUrl'] ?? '',
      sellerId: (json['sellerId'] is int) ? json['sellerId'].toString() : json['sellerId'],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((review) => Review.fromJson(review))
              .toList() ?? [],
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
      'sellerId': sellerId,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? price,
    String? originalPrice,
    String? imageUrl,
    String? sellerId,
    List<Review>? reviews,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      reviews: reviews ?? this.reviews,
    );
  }
}