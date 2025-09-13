import 'package:equatable/equatable.dart';
import 'package:intellicart/data/models/product_model.dart';
import 'package:intellicart/domain/entities/cart_item.dart';

/// Data model for a cart item.
///
/// This class represents a cart item in the data layer and is used for
/// serializing and deserializing cart item data to and from the database.
class CartItemModel extends Equatable {
  /// The unique identifier for this cart item.
  final int id;

  /// The product associated with this cart item.
  final ProductModel product;

  /// The quantity of the product in the cart.
  final int quantity;

  /// Creates a new cart item model.
  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
  });

  /// Creates a cart item model from a cart item entity.
  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      id: entity.id,
      product: ProductModel.fromEntity(entity.product),
      quantity: entity.quantity,
    );
  }

  /// Converts this cart item model to a cart item entity.
  CartItem toEntity() {
    return CartItem(
      id: id,
      product: product.toEntity(),
      quantity: quantity,
    );
  }

  /// Creates a copy of this cart item model with the given fields replaced.
  CartItemModel copyWith({
    int? id,
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Converts this cart item model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  /// Creates a cart item model from a JSON map.
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity];
}