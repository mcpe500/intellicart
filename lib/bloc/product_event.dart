import 'package:intellicart/models/product.dart';
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {}

class LoadLocalProducts extends ProductEvent {}

class CreateProduct extends ProductEvent {
  final Product product;

  const CreateProduct(this.product);

  @override
  List<Object> get props => [product];
}

class SyncProducts extends ProductEvent {}