import 'package:intellicart/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {}

class LoadLocalProducts extends ProductEvent {}

class CreateProductEvent extends ProductEvent {
  final Product product;

  const CreateProductEvent(this.product);

  @override
  List<Object> get props => [product];
}

class SyncProductsEvent extends ProductEvent {
  final List<Product> products;

  const SyncProductsEvent(this.products);

  @override
  List<Object> get props => [products];
}