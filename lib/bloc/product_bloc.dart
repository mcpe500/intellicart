import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/bloc/product_event.dart';
import 'package:intellicart/bloc/product_state.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/services/api_service.dart';
import 'package:intellicart/services/database_service.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiService apiService;
  final DatabaseService databaseService;

  ProductBloc({required this.apiService, required this.databaseService}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProduct>(_onCreateProduct);
    on<LoadLocalProducts>(_onLoadLocalProducts);
    on<SyncProducts>(_onSyncProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      // First, try to load from local database
      final localProducts = await databaseService.readAll();
      
      // If we have local data, emit it immediately
      if (localProducts.isNotEmpty) {
        emit(ProductLoaded(localProducts));
      }
      
      // Then try to fetch from API
      final products = await apiService.getProducts();
      
      // Update local database with fresh data
      await _updateLocalDatabase(products);
      
      // Emit the fresh data
      emit(ProductLoaded(products));
    } catch (e) {
      // If API fails, try to load from local database
      try {
        final localProducts = await databaseService.readAll();
        if (localProducts.isNotEmpty) {
          emit(ProductLoaded(localProducts));
        } else {
          emit(ProductError('No products available'));
        }
      } catch (dbError) {
        emit(ProductError('Failed to load products: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadLocalProducts(LoadLocalProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await databaseService.readAll();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError('Failed to load local products: ${e.toString()}'));
    }
  }

  Future<void> _onCreateProduct(CreateProduct event, Emitter<ProductState> emit) async {
    try {
      // Save to local database first
      final localProduct = await databaseService.create(event.product);
      
      // Try to sync with API
      try {
        final newProduct = await apiService.createProduct(localProduct);
        // Update local database with product from API (which might have an updated ID)
        await databaseService.update(newProduct);
        
        // Reload all products to show the updated list
        add(LoadProducts());
      } catch (apiError) {
        // If API fails, we still have the local product
        // Reload all products to show the updated list
        add(LoadLocalProducts());
      }
    } catch (e) {
      emit(ProductError('Failed to create product: ${e.toString()}'));
    }
  }

  Future<void> _onSyncProducts(SyncProducts event, Emitter<ProductState> emit) async {
    try {
      final products = await apiService.getProducts();
      await _updateLocalDatabase(products);
      add(LoadLocalProducts());
    } catch (e) {
      emit(ProductError('Failed to sync products: ${e.toString()}'));
    }
  }

  Future<void> _updateLocalDatabase(List<Product> products) async {
    // Clear existing data
    final db = await databaseService.database;
    await db.delete('products');
    
    // Insert fresh data
    for (var product in products) {
      await databaseService.create(product);
    }
  }
}