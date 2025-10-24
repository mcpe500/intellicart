// lib/models/order.dart
import 'package:intellicart_frontend/models/product.dart';

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final List<Product> items;
  final double total;
  final String status; // e.g., "Pending", "Shipped", "Delivered"
  final DateTime orderDate;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.total,
    required this.status,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<Product> items = [];
    if (json['items'] != null) {
      items = (json['items'] as List)
          .map((itemJson) => Product.fromJson(itemJson))
          .toList();
    }

    return Order(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      items: items,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending',
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}