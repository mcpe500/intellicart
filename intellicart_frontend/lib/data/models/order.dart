// lib/data/models/order.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order extends Equatable {
  final String id;
  final String buyerId;
  final String sellerId;
  final String customerName;
  final List<String> productIds; // References to product IDs
  final double total;
  final String status; // e.g., "Pending", "Shipped", "Delivered"
  final String orderDate;

  const Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.customerName,
    required this.productIds,
    required this.total,
    required this.status,
    required this.orderDate,
  });

  @override
  List<Object> get props => [id, buyerId, sellerId, customerName, productIds, total, status, orderDate];

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}