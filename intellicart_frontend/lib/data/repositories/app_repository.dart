// lib/data/repositories/app_repository.dart
<<<<<<< HEAD
import 'package:intellicart/models/product.dart';
=======
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/models/order.dart';
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

abstract class AppRepository {
  Future<void> setAppMode(String mode);
  Future<String> getAppMode();
  Future<void> insertProducts(List<Product> products);
  Future<List<Product>> getProducts();
<<<<<<< HEAD
}
=======
  Future<List<Order>> getSellerOrders({String? status, int? page, int? limit});
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> deleteProduct(Product product);
  Future<Product> updateProduct(Product product);
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
