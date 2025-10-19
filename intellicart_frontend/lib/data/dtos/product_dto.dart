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
    return ProductDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as double?) ?? 0.0,
      originalPrice: (json['originalPrice'] is int) 
          ? (json['originalPrice'] as int).toDouble() 
          : (json['originalPrice'] as double?),
      imageUrl: json['imageUrl'] ?? '',
      sellerId: json['sellerId'] ?? '',
      categoryId: json['categoryId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      reviews: json['reviews'] ?? [],
      averageRating: (json['averageRating'] is int) 
          ? (json['averageRating'] as int).toDouble() 
          : (json['averageRating'] as double?),
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