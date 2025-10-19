// lib/data/models/wishlist_item.dart
class WishlistItem {
  final int? id; // ID for database storage
  final String productId;
  final String productName;
  final String productDescription;
  final String productPrice;
  final String productImageUrl;

  WishlistItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productPrice': productPrice,
      'productImageUrl': productImageUrl,
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'],
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productDescription: map['productDescription'] ?? '',
      productPrice: map['productPrice'] ?? '',
      productImageUrl: map['productImageUrl'] ?? '',
    );
  }
}