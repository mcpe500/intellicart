// lib/models/order.dart
import 'package:intellicart/models/product.dart';

class Order {
  final String id;
  final String customerName;
  final List<Product> items;
  final double total;
  final String status; // e.g., "Pending", "Shipped", "Delivered"
  final DateTime orderDate;

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.total,
    required this.status,
    required this.orderDate,
  });
}