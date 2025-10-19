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
    return Order(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item))
              .toList() ?? [],
      total: (json['total'] is int) ? (json['total'] as int).toDouble() : (json['total'] as double?) ?? 0.0,
      status: json['status'] ?? '',
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
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
