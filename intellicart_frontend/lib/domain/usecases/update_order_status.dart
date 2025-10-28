import '../repositories/order_repository.dart';

class UpdateOrderStatus {
  final OrderRepository repository;

  UpdateOrderStatus(this.repository);

  Future<void> call(String orderId, String status) {
    return repository.updateOrderStatus(orderId, status);
  }
}