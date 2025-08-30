import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/product_event.dart';
import 'package:intellicart/presentation/bloc/product_state.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/sync_products.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProducts getAllProducts;
  final CreateProduct createProductUseCase;
  final SyncProducts syncProductsUseCase;

  ProductBloc({
    required this.getAllProducts,
    required this.createProductUseCase,
    required this.syncProductsUseCase,
  }) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<LoadLocalProducts>(_onLoadLocalProducts);
    on<SyncProductsEvent>(_onSyncProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError('Failed to load products: ${e.toString()}'));
    }
  }

  Future<void> _onLoadLocalProducts(LoadLocalProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      // For this example, we'll just reload all products
      // In a real app, you might have a separate use case for this
      final products = await getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError('Failed to load local products: ${e.toString()}'));
    }
  }

  Future<void> _onCreateProduct(CreateProductEvent event, Emitter<ProductState> emit) async {
    try {
      await createProductUseCase(event.product);
      // Reload all products to show the updated list
      add(LoadProducts());
    } catch (e) {
      emit(ProductError('Failed to create product: ${e.toString()}'));
    }
  }

  Future<void> _onSyncProducts(SyncProductsEvent event, Emitter<ProductState> emit) async {
    try {
      await syncProductsUseCase(event.products);
      add(LoadLocalProducts());
    } catch (e) {
      emit(ProductError('Failed to sync products: ${e.toString()}'));
    }
  }
}