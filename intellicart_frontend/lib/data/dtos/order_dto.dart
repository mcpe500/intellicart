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
    // Helper function to parse numeric values that might be string, int, or double
    double parseNumber(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Remove currency symbols and other non-numeric characters before parsing
        final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
        return double.tryParse(cleanValue) ?? 0.0;
      }
      return 0.0;
    }

    return OrderDto(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      total: parseNumber(json['total']),
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
    // Helper function to parse price values that might be string, int, or double
    double parsePrice(dynamic priceValue) {
      if (priceValue == null) return 0.0;
      if (priceValue is double) return priceValue;
      if (priceValue is int) return priceValue.toDouble();
      if (priceValue is String) {
        // Remove currency symbols and other non-numeric characters before parsing
        final cleanValue = priceValue.replaceAll(RegExp(r'[^\d.-]'), '');
        return double.tryParse(cleanValue) ?? 0.0;
      }
      return 0.0;
    }

    return OrderItemDto(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: parsePrice(json['price']),
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