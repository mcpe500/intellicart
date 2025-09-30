import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/delete_product.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/sync_products.dart';
import 'package:intellicart/domain/usecases/update_product.dart';
import 'package:intellicart/presentation/bloc/product/product_event.dart';
import 'package:intellicart/presentation/bloc/product/product_state.dart';

/// BLoC for managing product state.
///
/// This BLoC handles all product-related events and manages the state
/// of products in the application.
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProducts _getAllProducts;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final SyncProducts _syncProducts;

  /// Creates a new product BLoC.
  ProductBloc({
    required GetAllProducts getAllProducts,
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
    required SyncProducts syncProducts,
  })  : _getAllProducts = getAllProducts,
        _createProduct = createProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct,
        _syncProducts = syncProducts,
        super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<SyncProductsEvent>(_onSyncProducts);
  }

  /// Handles the LoadProducts event.
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await _getAllProducts();
      emit(ProductLoaded(products));
    } on AppException catch (e) {
      emit(ProductError(e.toString()));
    } catch (e) {
      emit(ProductError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the CreateProductEvent.
  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    // Get current state
    final currentState = state;
    List<Product> currentProducts = [];
    if (currentState is ProductLoaded) {
      currentProducts = List.from(currentState.products);
    }

    try {
      final newProduct = await _createProduct(event.product);
      currentProducts.add(newProduct);
      emit(ProductLoaded(currentProducts));
    } on AppException catch (e) {
      emit(ProductError(e.toString()));
    } catch (e) {
      emit(ProductError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the UpdateProductEvent.
  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    // Get current state
    final currentState = state;
    List<Product> currentProducts = [];
    if (currentState is ProductLoaded) {
      currentProducts = List.from(currentState.products);
    }

    try {
      final updatedProduct = await _updateProduct(event.product);
      final index = currentProducts.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        currentProducts[index] = updatedProduct;
        emit(ProductLoaded(currentProducts));
      }
    } on AppException catch (e) {
      emit(ProductError(e.toString()));
    } catch (e) {
      emit(ProductError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the DeleteProductEvent.
  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    // Get current state
    final currentState = state;
    List<Product> currentProducts = [];
    if (currentState is ProductLoaded) {
      currentProducts = List.from(currentState.products);
    }

    try {
      await _deleteProduct(event.productId);
      currentProducts.removeWhere((p) => p.id == event.productId);
      emit(ProductLoaded(currentProducts));
    } on AppException catch (e) {
      emit(ProductError(e.toString()));
    } catch (e) {
      emit(ProductError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the SyncProductsEvent.
  Future<void> _onSyncProducts(
    SyncProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      await _syncProducts(event.products);
      emit(ProductLoaded(event.products));
    } on AppException catch (e) {
      emit(ProductError(e.toString()));
    } catch (e) {
      emit(ProductError('An unexpected error occurred: ${e.toString()}'));
    }
  }
}