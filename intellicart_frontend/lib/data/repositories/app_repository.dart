// lib/data/repositories/app_repository.dart
import 'package:intellicart_frontend/models/product.dart';

abstract class AppRepository {
  Future<void> setAppMode(String mode);
  Future<String> getAppMode();
  Future<void> insertProducts(List<Product> products);
  Future<List<Product>> getProducts();
}
