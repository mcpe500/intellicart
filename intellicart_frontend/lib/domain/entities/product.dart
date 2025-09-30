import 'package:equatable/equatable.dart';

/// A product in the shopping cart.
///
/// This class represents a product that can be added to a shopping cart.
/// It contains information such as [name], [description], [price], and [imageUrl].
///
/// Example:
/// ```dart
/// final product = Product(
///   id: 1,
///   name: 'Wireless Keyboard',
///   description: 'Ergonomic wireless keyboard with long battery life',
///   price: 29.99,
///   imageUrl: 'https://example.com/keyboard.jpg',
/// );
/// ```
class Product extends Equatable {
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

  /// Creates a new product.
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  /// Creates a copy of this product with the given fields replaced.
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Converts this product to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  /// Creates a product from a JSON map.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
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