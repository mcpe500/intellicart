// lib/data/models/cart_item.dart
class CartItem {
  final int? id; // ID for database storage
  final String productId;
  final String productName;
  final String productDescription;
  final String productPrice;
  final String productImageUrl;
  final int quantity;

  CartItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productImageUrl,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productPrice': productPrice,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productDescription: map['productDescription'] ?? '',
      productPrice: map['productPrice'] ?? '',
      productImageUrl: map['productImageUrl'] ?? '',
      quantity: map['quantity']?.toInt() ?? 1,
    );
  }
}