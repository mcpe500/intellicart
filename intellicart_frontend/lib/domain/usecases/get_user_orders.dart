import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetUserOrders {
  final OrderRepository repository;

  GetUserOrders(this.repository);

  Future<List<Order>> call(String userId) {
    return repository.getUserOrders(userId);
  }
}