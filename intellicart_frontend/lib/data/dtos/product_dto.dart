// lib/data/dtos/product_dto.dart

class ProductDto {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String sellerId;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic> reviews; // Will be processed separately
  final double? averageRating;
  
  ProductDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.sellerId,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.reviews,
    this.averageRating,
  });
  
  factory ProductDto.fromJson(Map<String, dynamic> json) {
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

    return ProductDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parsePrice(json['price']),
      originalPrice: json['originalPrice'] != null ? parsePrice(json['originalPrice']) : null,
      imageUrl: json['imageUrl'] ?? '',
      sellerId: json['sellerId'] ?? '',
      categoryId: json['categoryId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      reviews: json['reviews'] ?? [],
      averageRating: json['averageRating'] != null ? parsePrice(json['averageRating']) : null,
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
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reviews': reviews,
      'averageRating': averageRating,
    };
  }
}