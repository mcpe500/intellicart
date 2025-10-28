import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getUserOrders(String userId);
  Future<void> createOrder(Order order);
  Future<void> updateOrderStatus(String orderId, String status);
}