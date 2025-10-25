// lib/models/order.dart
import 'package:intellicart/models/product.dart';

class Order {
  final dynamic id;  // Can be int or String depending on backend
  final String customerName;
  final List<Product> items;
  final double total;
  final String status; // e.g., "Pending", "Shipped", "Delivered"
  final DateTime orderDate;

  Order({
    this.id,
    required this.customerName,
    required this.items,
    required this.total,
    required this.status,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customerName'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item))
              .toList() ?? [],
      total: (json['total'] is int) ? (json['total'] as int).toDouble() : json['total']?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}