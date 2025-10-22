// lib/data/models/wishlist_item.dart
class WishlistItem {
  final String productId;
  final String productName;
  final String productDescription;
  final String productPrice;
  final String? productOriginalPrice;
  final String productImageUrl;
  final DateTime addedAt;

  WishlistItem({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    this.productOriginalPrice,
    required this.productImageUrl,
    required this.addedAt,
  });

  WishlistItem copyWith({
    String? productId,
    String? productName,
    String? productDescription,
    String? productPrice,
    String? productOriginalPrice,
    String? productImageUrl,
    DateTime? addedAt,
  }) {
    return WishlistItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productPrice: productPrice ?? this.productPrice,
      productOriginalPrice: productOriginalPrice ?? this.productOriginalPrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productDescription: json['productDescription'] ?? '',
      productPrice: json['productPrice'] ?? '',
      productOriginalPrice: json['productOriginalPrice'],
      productImageUrl: json['productImageUrl'] ?? '',
      addedAt: json['addedAt'] != null ? DateTime.parse(json['addedAt']) : DateTime.now(),
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
      'addedAt': addedAt.toIso8601String(),
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
      'addedAt': addedAt.toIso8601String(),
    };
  }
  
  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productDescription: map['productDescription'] ?? '',
      productPrice: map['productPrice'] ?? '',
      productOriginalPrice: map['productOriginalPrice'],
      productImageUrl: map['productImageUrl'] ?? '',
      addedAt: map['addedAt'] != null ? DateTime.parse(map['addedAt']) : DateTime.now(),
    );
  }
}