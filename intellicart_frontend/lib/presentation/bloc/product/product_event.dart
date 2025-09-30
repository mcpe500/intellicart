import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/product.dart';

/// Base class for all product events.
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

/// Event to load all products.
class LoadProducts extends ProductEvent {}

/// Event to create a new product.
class CreateProductEvent extends ProductEvent {
  final Product product;

  const CreateProductEvent(this.product);

  @override
  List<Object> get props => [product];
}

/// Event to update an existing product.
class UpdateProductEvent extends ProductEvent {
  final Product product;

  const UpdateProductEvent(this.product);

  @override
  List<Object> get props => [product];
}

/// Event to delete a product.
class DeleteProductEvent extends ProductEvent {
  final int productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object> get props => [productId];
}

/// Event to sync products.
class SyncProductsEvent extends ProductEvent {
  final List<Product> products;

  const SyncProductsEvent(this.products);

  @override
  List<Object> get props => [products];
}