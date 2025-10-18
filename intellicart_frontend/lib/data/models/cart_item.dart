import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final int? id;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final DateTime createdAt;

  const CartItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.createdAt,
  });

  CartItem copyWith({
    int? id,
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id']?.toInt(),
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 0,
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  @override
  List<Object?> get props => [id, productId, productName, price, quantity, imageUrl, createdAt];
}
