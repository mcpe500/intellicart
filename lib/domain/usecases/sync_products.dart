import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';

class SyncProducts {
  final ProductRepository repository;

  SyncProducts(this.repository);

  Future<void> call(List<Product> products) async {
    return await repository.syncProducts(products);
  }
}