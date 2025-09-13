import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/product.dart';

/// Data model for a product.
///
/// This class represents a product in the data layer and is used for
/// serializing and deserializing product data to and from the database.
class ProductModel extends Equatable {
  /// The unique identifier for this product.
  final int id;

  /// The name of the product.
  final String name;

  /// A detailed description of the product.
  final String description;

  /// The price of the product in USD.
  final double price;

  /// URL to an image of the product.
  final String imageUrl;

  /// Creates a new product model.
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  /// Creates a product model from a product entity.
  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      imageUrl: entity.imageUrl,
    );
  }

  /// Converts this product model to a product entity.
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
    );
  }

  /// Creates a copy of this product model with the given fields replaced.
  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Converts this product model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  /// Creates a product model from a JSON map.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, description, price, imageUrl];
}