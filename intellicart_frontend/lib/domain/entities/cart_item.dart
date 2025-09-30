import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/product.dart';

/// A cart item in the shopping cart.
///
/// This class represents an item that has been added to a shopping cart.
/// It contains a reference to the [product] and the [quantity] of that product.
///
/// Example:
/// ```dart
/// final cartItem = CartItem(
///   id: 1,
///   product: Product(
///     id: 1,
///     name: 'Wireless Keyboard',
///     description: 'Ergonomic wireless keyboard with long battery life',
///     price: 29.99,
///     imageUrl: 'https://example.com/keyboard.jpg',
///   ),
///   quantity: 2,
/// );
/// ```
class CartItem extends Equatable {
  /// The unique identifier for this cart item.
  final int id;

  /// The product associated with this cart item.
  final Product product;

  /// The quantity of the product in the cart.
  final int quantity;

  /// Creates a new cart item.
  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  /// The total price for this cart item (product price * quantity).
  double get totalPrice => product.price * quantity;

  /// Creates a copy of this cart item with the given fields replaced.
  CartItem copyWith({
    int? id,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Converts this cart item to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  /// Creates a cart item from a JSON map.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity];
}