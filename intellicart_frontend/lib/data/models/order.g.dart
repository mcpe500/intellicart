// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String,
  buyerId: json['buyerId'] as String,
  sellerId: json['sellerId'] as String,
  customerName: json['customerName'] as String,
  productIds: (json['productIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  total: (json['total'] as num).toDouble(),
  status: json['status'] as String,
  orderDate: json['orderDate'] as String,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'buyerId': instance.buyerId,
  'sellerId': instance.sellerId,
  'customerName': instance.customerName,
  'productIds': instance.productIds,
  'total': instance.total,
  'status': instance.status,
  'orderDate': instance.orderDate,
};
