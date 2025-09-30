part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}

class FilterProducts extends ProductEvent {
  final Map<String, dynamic> filters;

  const FilterProducts(this.filters);

  @override
  List<Object> get props => [filters];
}

class LoadProductDetails extends ProductEvent {
  final String productId;

  const LoadProductDetails(this.productId);

  @override
  List<Object> get props => [productId];
}