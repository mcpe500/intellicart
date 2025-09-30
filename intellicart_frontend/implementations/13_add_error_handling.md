# 13 - Add Error Handling

## Overview
This step involves implementing comprehensive error handling throughout the Intellicart application. We'll create custom exceptions, implement error handling in repositories, use cases, BLoCs, and UI components to ensure a robust and user-friendly error experience.

## Implementation Details

### 1. Create Custom Exceptions

Create `lib/core/errors/app_exceptions.dart`:

```dart
class AppException implements Exception {
  final String message;
  final String? prefix;
  final String? url;

  AppException([this.message = '', this.prefix = '', this.url = '']);

  @override
  String toString() {
    return '$prefix$message';
  }
}

class NetworkException extends AppException {
  NetworkException([String? message]) : super(message, 'Network Error: ');
}

class DatabaseException extends AppException {
  DatabaseException([String? message]) : super(message, 'Database Error: ');
}

class ValidationException extends AppException {
  ValidationException([String? message]) : super(message, 'Validation Error: ');
}

class AuthenticationException extends AppException {
  AuthenticationException([String? message]) : super(message, 'Authentication Error: ');
}

class ProductNotFoundException extends AppException {
  ProductNotFoundException([String? message]) : super(message, 'Product Not Found: ');
}

class UserNotAuthenticatedException extends AppException {
  UserNotAuthenticatedException([String? message])
      : super(message, 'User Not Authenticated: ');
}

class CartException extends AppException {
  CartException([String? message]) : super(message, 'Cart Error: ');
}
```

### 2. Update Data Sources with Error Handling

Update `lib/data/datasources/product_firestore_data_source.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intellicart/data/models/product_model.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';

class ProductFirestoreDataSource {
  final FirebaseFirestore firestore;

  ProductFirestoreDataSource({required this.firestore});

  CollectionReference get productsCollection => firestore.collection('products');

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final querySnapshot = await productsCollection.get();
      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>)
              .copyWith(id: doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get products: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unexpected error while getting products: $e');
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final docSnapshot = await productsCollection.doc(id).get();
      if (!docSnapshot.exists) {
        throw ProductNotFoundException('Product with id $id not found');
      }
      return ProductModel.fromJson(docSnapshot.data() as Map<String, dynamic>)
          .copyWith(id: docSnapshot.id);
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get product: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unexpected error while getting product: $e');
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final querySnapshot = await productsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>)
              .copyWith(id: doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to search products: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unexpected error while searching products: $e');
    }
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final docRef = await productsCollection.add(product.toJson());
      final docSnapshot = await docRef.get();
      return ProductModel.fromJson(docSnapshot.data() as Map<String, dynamic>)
          .copyWith(id: docSnapshot.id);
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to create product: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unexpected error while creating product: $e');
    }
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      await productsCollection.doc(product.id).update(product.toJson());
      return product;
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to update product: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unexpected error while updating product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await productsCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to delete product: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unexpected error while deleting product: $e');
    }
  }
}
```

### 3. Update Repository Implementations with Error Handling

Update `lib/data/repositories/product_repository_impl.dart`:

```dart
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:intellicart/data/datasources/product_firestore_data_source.dart';
import 'package:intellicart/data/models/product_model.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductFirestoreDataSource dataSource;

  ProductRepositoryImpl({required this.dataSource});

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final productModels = await dataSource.getAllProducts();
      return productModels.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow; // Re-throw our custom exceptions
    } catch (e) {
      throw DatabaseException('Unexpected error in product repository: $e');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final productModel = await dataSource.getProductById(id);
      return productModel.toEntity();
    } on AppException {
      rethrow; // Re-throw our custom exceptions
    } catch (e) {
      throw DatabaseException('Unexpected error in product repository: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final productModels = await dataSource.searchProducts(query);
      return productModels.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow; // Re-throw our custom exceptions
    } catch (e) {
      throw DatabaseException('Unexpected error in product repository: $e');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final createdModel = await dataSource.createProduct(productModel);
      return createdModel.toEntity();
    } on AppException {
      rethrow; // Re-throw our custom exceptions
    } catch (e) {
      throw DatabaseException('Unexpected error in product repository: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final updatedModel = await dataSource.updateProduct(productModel);
      return updatedModel.toEntity();
    } on AppException {
      rethrow; // Re-throw our custom exceptions
    } catch (e) {
      throw DatabaseException('Unexpected error in product repository: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      return await dataSource.deleteProduct(id);
    } on AppException {
      rethrow; // Re-throw our custom exceptions
    } catch (e) {
      throw DatabaseException('Unexpected error in product repository: $e');
    }
  }
}
```

### 4. Update Use Cases with Error Handling

Update `lib/domain/usecases/create_product.dart`:

```dart
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<Product> call(Product product) async {
    try {
      // Business logic validation
      if (product.name.isEmpty) {
        throw ValidationException('Product name cannot be empty');
      }
      if (product.price < 0) {
        throw ValidationException('Product price must be positive');
      }
      return await repository.createProduct(product);
    } on AppException {
      rethrow; // Re-throw our custom exceptions
    } catch (e) {
      throw AppException('Unexpected error while creating product: $e');
    }
  }
}
```

### 5. Update BLoCs with Error Handling

Update `lib/presentation/bloc/product/product_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/update_product.dart';
import 'package:intellicart/domain/usecases/delete_product.dart';
import 'package:intellicart/domain/usecases/search_products.dart';
import 'package:intellicart/presentation/bloc/product/product_event.dart';
import 'package:intellicart/presentation/bloc/product/product_state.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProducts getAllProducts;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;
  final SearchProducts searchProducts;

  ProductBloc({
    required this.getAllProducts,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
    required this.searchProducts,
  }) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<SearchProductsEvent>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await getAllProducts();
      emit(ProductLoaded(products));
    } on AppException catch (e) {
      emit(ProductError(e.toString()));
    } catch (e) {
      emit(ProductError('Unexpected error: $e'));
    }
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await searchProducts(event.query);
      emit(ProductLoaded(products));
    } on AppException catch (e) {
      emit(ProductError(e.toString()));
    } catch (e) {
      emit(ProductError('Unexpected error: $e'));
    }
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await createProduct(event.product);
      // Reload products after creation
      final products = await getAllProducts();
      emit(ProductLoaded(products));
    } on AppException catch (e) {
      emit(ProductError(e.toString()));
    } catch (e) {
      emit(ProductError('Unexpected error: $e'));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await updateProduct(event.product);
      // Reload products after update
      final products = await getAllProducts();
      emit(ProductLoaded(products));
    } on AppException catch (e) {
      emit(ProductError(e.toString()));
    } catch (e) {
      emit(ProductError('Unexpected error: $e'));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await deleteProduct(event.productId);
      // Reload products after deletion
      final products = await getAllProducts();
      emit(ProductLoaded(products));
    } on AppException catch (e) {
      emit(ProductError(e.toString()));
    } catch (e) {
      emit(ProductError('Unexpected error: $e'));
    }
  }
}
```

### 6. Create Error Handling Utilities

Create `lib/core/utils/error_handler.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';

class ErrorHandler {
  static String mapExceptionToMessage(Exception exception) {
    if (exception is AppException) {
      return exception.toString();
    }
    return 'An unexpected error occurred: ${exception.toString()}';
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
```

### 7. Update UI Components with Error Handling

Update `lib/presentation/widgets/product_list.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/widgets/product_list_item.dart';
import 'package:intellicart/core/utils/error_handler.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductLoaded) {
          return ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductListItem(product: product);
            },
          );
        }
        if (state is ProductError) {
          // Show error message and provide retry option
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProductBloc>().add(LoadProducts());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('No products found'));
      },
    );
  }
}
```

## Design Considerations

### 1. Custom Exception Hierarchy
We've created a hierarchy of custom exceptions that provide more specific error information than generic exceptions.

### 2. Consistent Error Handling
Error handling is consistent across all layers of the application, from data sources to UI components.

### 3. User-Friendly Error Messages
We're providing user-friendly error messages that help users understand what went wrong and how to potentially fix it.

### 4. Error Recovery Options
UI components provide options for users to retry failed operations when appropriate.

### 5. Exception Re-throwing
Lower layers re-throw custom exceptions to allow upper layers to handle them appropriately.

## Verification

To verify this step is complete:

1. All custom exception classes should exist in `lib/core/errors/`
2. Data sources should properly handle and convert Firebase exceptions
3. Repositories should re-throw custom exceptions
4. Use cases should implement business logic validation
5. BLoCs should catch and emit appropriate error states
6. UI components should display user-friendly error messages
7. Error handling utilities should be available for consistent error presentation

## Code Quality Checks

1. All exceptions should have descriptive names and messages
2. Error handling should be consistent across all components
3. User-facing error messages should be clear and helpful
4. Technical error details should be logged but not exposed to users
5. Error recovery options should be provided where appropriate

## Next Steps

After completing this step, we can move on to implementing the authentication flow for our application.