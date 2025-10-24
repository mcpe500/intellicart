import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String description;
  final String? imageUrl;
  final String category;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.imageUrl,
    required this.category,
    this.tags = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? category,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    bool? inStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'tags': tags,
      'rating': rating,
      'review_count': reviewCount,
      'in_stock': inStock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    // Helper function to parse price values that might be string, int, or double
    double parsePrice(dynamic priceValue) {
      if (priceValue == null) return 0.0;
      if (priceValue is double) return priceValue;
      if (priceValue is int) return priceValue.toDouble();
      if (priceValue is String) {
        // Remove currency symbols and other non-numeric characters before parsing
        final cleanValue = priceValue.replaceAll(RegExp(r'[^\d.-]'), '');
        return double.tryParse(cleanValue) ?? 0.0;
      }
      return 0.0;
    }

    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: parsePrice(map['price']),
      description: map['description'] ?? '',
      imageUrl: map['image_url'],
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      rating: map['rating'] != null ? parsePrice(map['rating']) : 0.0,
      reviewCount: map['review_count']?.toInt() ?? 0,
      inStock: map['in_stock'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        description,
        imageUrl,
        category,
        tags,
        rating,
        reviewCount,
        inStock,
        createdAt,
        updatedAt,
      ];
}
