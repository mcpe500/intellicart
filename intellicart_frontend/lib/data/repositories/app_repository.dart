// lib/data/repositories/app_repository.dart
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/models/order.dart';

abstract class AppRepository {
  Future<void> setAppMode(String mode);
  Future<String> getAppMode();
  Future<void> insertProducts(List<Product> products);
  Future<List<Product>> getProducts();
  Future<List<Order>> getSellerOrders({String? status, int? page, int? limit});
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> deleteProduct(Product product);
  Future<Product> updateProduct(Product product);
}
