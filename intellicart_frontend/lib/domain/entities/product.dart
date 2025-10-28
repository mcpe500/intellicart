import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int quantity;
  final String imageUrl;
  final String sellerId;
  final double rating;
  final int reviewCount;
  final String category;
  final List<dynamic>? reviews;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.quantity,
    required this.imageUrl,
    required this.sellerId,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.category,
    this.reviews,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        originalPrice,
        quantity,
        imageUrl,
        sellerId,
        rating,
        reviewCount,
        category,
        reviews,
        createdAt,
      ];

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    int? quantity,
    String? imageUrl,
    String? sellerId,
    double? rating,
    int? reviewCount,
    String? category,
    List<dynamic>? reviews,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      category: category ?? this.category,
      reviews: reviews ?? this.reviews,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'reviews': reviews,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      originalPrice: json['originalPrice']?.toDouble(),
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      sellerId: json['sellerId'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      category: json['category'] ?? '',
      reviews: json['reviews'],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : null,
    );
  }
}