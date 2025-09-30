import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/product.dart';

/// Base class for all product states.
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

/// Initial state for the product BLoC.
class ProductInitial extends ProductState {}

/// State when products are being loaded.
class ProductLoading extends ProductState {}

/// State when products have been successfully loaded.
class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  List<Object> get props => [products];
}

/// State when there is an error loading products.
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}