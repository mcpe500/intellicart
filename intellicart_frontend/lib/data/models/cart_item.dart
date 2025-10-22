// lib/data/models/cart_item.dart
class CartItem {
  final String productId;
  final String productName;
  final String productDescription;
  final String productPrice;
  final String? productOriginalPrice;
  final String productImageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    this.productOriginalPrice,
    required this.productImageUrl,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? productId,
    String? productName,
    String? productDescription,
    String? productPrice,
    String? productOriginalPrice,
    String? productImageUrl,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productPrice: productPrice ?? this.productPrice,
      productOriginalPrice: productOriginalPrice ?? this.productOriginalPrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productDescription: json['productDescription'] ?? '',
      productPrice: json['productPrice'] ?? '',
      productOriginalPrice: json['productOriginalPrice'],
      productImageUrl: json['productImageUrl'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productPrice': productPrice,
      'productOriginalPrice': productOriginalPrice,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
    };
  }
  
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productPrice': productPrice,
      'productOriginalPrice': productOriginalPrice,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
    };
  }
  
 factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productDescription: map['productDescription'] ?? '',
      productPrice: map['productPrice'] ?? '',
      productOriginalPrice: map['productOriginalPrice'],
      productImageUrl: map['productImageUrl'] ?? '',
      quantity: map['quantity']?.toInt() ?? 1,
    );
  }
}