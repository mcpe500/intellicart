// lib/presentation/bloc/seller_product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/review.dart';
=======
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/data/repositories/app_repository_impl.dart';

>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

// --- EVENTS ---
abstract class SellerProductEvent extends Equatable {
  const SellerProductEvent();
  @override
  List<Object> get props => [];
}

class LoadSellerProducts extends SellerProductEvent {}

class AddSellerProduct extends SellerProductEvent {
  final Product product;
  const AddSellerProduct(this.product);
  @override
  List<Object> get props => [product];
}

class UpdateSellerProduct extends SellerProductEvent {
  final Product product;
  const UpdateSellerProduct(this.product);
  @override
  List<Object> get props => [product];
}

class DeleteSellerProduct extends SellerProductEvent {
  final Product product;
  const DeleteSellerProduct(this.product);
  @override
  List<Object> get props => [product];
}

// --- STATES ---
abstract class SellerProductState extends Equatable {
  const SellerProductState();
  @override
  List<Object> get props => [];
}

class SellerProductLoading extends SellerProductState {}

class SellerProductLoaded extends SellerProductState {
  final List<Product> products;
  const SellerProductLoaded(this.products);
  @override
  List<Object> get props => [products];
}

class SellerProductError extends SellerProductState {
  final String error;
  const SellerProductError(this.error);
  @override
  List<Object> get props => [error];
}

// --- BLOC ---
class SellerProductBloc extends Bloc<SellerProductEvent, SellerProductState> {
<<<<<<< HEAD
  // Mock product list
  final List<Product> _products = [
    Product(
      name: 'My Store Product 1',
      description: 'Description for my product',
      price: '\$99.99',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAU7U_kS6_gA60CXLu3bQedKs7gieDR-Od4nf01tYU1wiMTn7rnT9gQjZJrXCWSbd3qSnnAb4ohNgEe6Rqkme_SFVx3pdpdg7dDl2RXverxSCbNfl06zi79wznmywgEy2tjT0vzBqLgdBrNAeOzxMZTVrYva74Y2ClHL8Nm9HUM4xqsf_MkIdsQAJntvJyEyYwBki7Vsq1huMtI8DDohIKbLItAlgtMAfQNC14jLnulQjuc74GOglQOVmneWnEV6ieRiEQrTXOZM_Sr0',
      reviews: [],
    ),
    Product(
      name: 'My Store Product 2',
      description: 'Another description',
      price: '\$12.50',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAU7U_kS6_gA60CXLu3bQedKs7gieDR-Od4nf01tYU1wiMTn7rnT9gQjZJrXCWSbd3qSnnAb4ohNgEe6Rqkme_SFVx3pdpdg7dDl2RXverxSCbNfl06zi79wznmywgEy2tjT0vzBqLgdBrNAeOzxMZTVrYva74Y2ClHL8Nm9HUM4xqsf_MkIdsQAJntvJyEyYwBki7Vsq1huMtI8DDohIKbLItAlgtMAfQNC14jLnulQjuc74GOglQOVmneWnEV6ieRiEQrTXOZM_Sr1',
      reviews: [],
    ),
  ];
=======
  final AppRepositoryImpl _repository = AppRepositoryImpl();
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

  SellerProductBloc() : super(SellerProductLoading()) {
    on<LoadSellerProducts>(_onLoadProducts);
    on<AddSellerProduct>(_onAddProduct);
    on<UpdateSellerProduct>(_onUpdateProduct);
    on<DeleteSellerProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
    LoadSellerProducts event,
    Emitter<SellerProductState> emit,
  ) async {
    emit(SellerProductLoading());
<<<<<<< HEAD
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate load
    emit(SellerProductLoaded(List.from(_products)));
=======
    try {
      final products = await _repository.getProducts(); // Note: This gets all products, not seller-specific
      // In a real implementation, we would need a method to get seller-specific products
      emit(SellerProductLoaded(products));
    } catch (e) {
      emit(SellerProductError(e.toString()));
    }
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
  }

  Future<void> _onAddProduct(
    AddSellerProduct event,
    Emitter<SellerProductState> emit,
  ) async {
<<<<<<< HEAD
    // In a real app, save to DB, then reload or update state
    _products.add(event.product);
    emit(SellerProductLoaded(List.from(_products)));
=======
    try {
      await _repository.insertProducts([event.product]);
      final products = await _repository.getProducts();
      emit(SellerProductLoaded(products));
    } catch (e) {
      emit(SellerProductError(e.toString()));
    }
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
  }

  Future<void> _onUpdateProduct(
    UpdateSellerProduct event,
    Emitter<SellerProductState> emit,
  ) async {
<<<<<<< HEAD
    // Find and update
    int index = _products.indexWhere((p) => p.name == event.product.name); // Using name as ID for mock
    if (index != -1) {
      _products[index] = event.product;
    }
    emit(SellerProductLoaded(List.from(_products)));
=======
    try {
      await _repository.updateProduct(event.product);
      final products = await _repository.getProducts();
      emit(SellerProductLoaded(products));
    } catch (e) {
      emit(SellerProductError(e.toString()));
    }
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
  }

  Future<void> _onDeleteProduct(
    DeleteSellerProduct event,
    Emitter<SellerProductState> emit,
  ) async {
<<<<<<< HEAD
    _products.removeWhere((p) => p.name == event.product.name);
    emit(SellerProductLoaded(List.from(_products)));
  }
}
=======
    try {
      await _repository.deleteProduct(event.product);
      final products = await _repository.getProducts();
      emit(SellerProductLoaded(products));
    } catch (e) {
      emit(SellerProductError(e.toString()));
    }
  }
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
