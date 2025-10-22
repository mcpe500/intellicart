part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductStateInitial extends ProductState {
  const ProductStateInitial();
}

class ProductStateLoading extends ProductState {
  const ProductStateLoading();
}

class ProductStateLoaded extends ProductState {
  final List<Product> products;

  const ProductStateLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductStateDetailsLoaded extends ProductState {
  final Product? product;

  const ProductStateDetailsLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductStateError extends ProductState {
  final String message;

  const ProductStateError(this.message);

  @override
  List<Object> get props => [message];
}
