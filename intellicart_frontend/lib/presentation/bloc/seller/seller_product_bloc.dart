// lib/presentation/bloc/seller_product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/data/repositories/app_repository_impl.dart';


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
  final AppRepositoryImpl _repository = AppRepositoryImpl();

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
    try {
      final products = await _repository.getProducts(); // Note: This gets all products, not seller-specific
      // In a real implementation, we would need a method to get seller-specific products
      emit(SellerProductLoaded(products));
    } catch (e) {
      emit(SellerProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
    AddSellerProduct event,
    Emitter<SellerProductState> emit,
  ) async {
    try {
      await _repository.insertProducts([event.product]);
      final products = await _repository.getProducts();
      emit(SellerProductLoaded(products));
    } catch (e) {
      emit(SellerProductError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateSellerProduct event,
    Emitter<SellerProductState> emit,
  ) async {
    try {
      await _repository.updateProduct(event.product);
      final products = await _repository.getProducts();
      emit(SellerProductLoaded(products));
    } catch (e) {
      emit(SellerProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteSellerProduct event,
    Emitter<SellerProductState> emit,
  ) async {
    try {
      await _repository.deleteProduct(event.product);
      final products = await _repository.getProducts();
      emit(SellerProductLoaded(products));
    } catch (e) {
      emit(SellerProductError(e.toString()));
    }
  }
}
