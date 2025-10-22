// lib/data/dtos/order_dto.dart

class OrderDto {
  final String id;
  final String customerId;
  final String customerName;
  final double total;
  final String status;
  final DateTime orderDate;
  final List<OrderItemDto> items;
  
  OrderDto({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.total,
    required this.status,
    required this.orderDate,
    required this.items,
  });
  
  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      total: (json['total'] is int) ? (json['total'] as int).toDouble() : (json['total'] as double?) ?? 0.0,
      status: json['status'] ?? '',
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemDto.fromJson(item))
              .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'total': total,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItemDto {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  
  OrderItemDto({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });
  
  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as double?) ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}