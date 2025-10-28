import '../repositories/product_repository.dart';

class SyncProducts {
  final ProductRepository repository;

  SyncProducts(this.repository);

  Future<void> call() {
    return repository.syncProducts();
  }
}