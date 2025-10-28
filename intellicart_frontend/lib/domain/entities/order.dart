import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String userId;
  final String productId;
  final String buyerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String? shippingAddress;
  final DateTime? createdAt;

  const Order({
    required this.id,
    required this.userId,
    required this.productId,
    required this.buyerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.shippingAddress,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        productId,
        buyerId,
        items,
        totalAmount,
        status,
        orderDate,
        shippingAddress,
        createdAt,
      ];

  Order copyWith({
    String? id,
    String? userId,
    String? productId,
    String? buyerId,
    List<OrderItem>? items,
    double? totalAmount,
    String? status,
    DateTime? orderDate,
    String? shippingAddress,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      buyerId: buyerId ?? this.buyerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'buyerId': buyerId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'shippingAddress': shippingAddress,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      orderDate: json['orderDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['orderDate'])
          : DateTime.now(),
      shippingAddress: json['shippingAddress'],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : null,
    );
  }
}

class OrderItem extends Equatable {
  final String productId;
  final int quantity;
  final double price;
  final String name;

  const OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.name,
  });

  @override
  List<Object?> get props => [productId, quantity, price, name];

  OrderItem copyWith({
    String? productId,
    int? quantity,
    double? price,
    String? name,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'name': name,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price']?.toDouble() ?? 0.0,
      name: json['name'] ?? '',
    );
  }
}