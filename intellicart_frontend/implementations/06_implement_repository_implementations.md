# 06 - Implement Repository Implementations

## Overview
This step involves implementing the repository interfaces using the Firebase data sources we created in the previous step. These implementations will bridge the gap between the domain layer (which defines what data operations are needed) and the data layer (which provides the actual implementation).

## Implementation Details

### 1. Implement Product Repository Implementation

Create `lib/data/repositories/product_repository_impl.dart`:

```dart
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:intellicart/data/datasources/product_firestore_data_source.dart';
import 'package:intellicart/data/models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductFirestoreDataSource dataSource;

  ProductRepositoryImpl({required this.dataSource});

  @override
  Future<List<Product>> getAllProducts() async {
    final productModels = await dataSource.getAllProducts();
    return productModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Product> getProductById(String id) async {
    final productModel = await dataSource.getProductById(id);
    return productModel.toEntity();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final productModels = await dataSource.searchProducts(query);
    return productModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Product> createProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);
    final createdModel = await dataSource.createProduct(productModel);
    return createdModel.toEntity();
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);
    final updatedModel = await dataSource.updateProduct(productModel);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteProduct(String id) async {
    return await dataSource.deleteProduct(id);
  }
}
```

### 2. Implement Cart Repository Implementation

Create `lib/data/repositories/cart_repository_impl.dart`:

```dart
import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';
import 'package:intellicart/data/datasources/cart_firestore_data_source.dart';
import 'package:intellicart/data/models/cart_item_model.dart';
import 'package:intellicart/data/models/product_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartFirestoreDataSource dataSource;

  CartRepositoryImpl({required this.dataSource});

  @override
  Future<List<CartItem>> getCartItems() async {
    final cartItemModels = await dataSource.getCartItems();
    return cartItemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CartItem> addItemToCart(Product product, int quantity) async {
    final productModel = ProductModel.fromEntity(product);
    final cartItemModel = await dataSource.addItemToCart(productModel, quantity);
    return cartItemModel.toEntity();
  }

  @override
  Future<CartItem> updateCartItem(CartItem item) async {
    final cartItemModel = CartItemModel.fromEntity(item);
    final updatedModel = await dataSource.updateCartItem(cartItemModel);
    return updatedModel.toEntity();
  }

  @override
  Future<void> removeItemFromCart(String itemId) async {
    return await dataSource.removeItemFromCart(itemId);
  }

  @override
  Future<void> clearCart() async {
    return await dataSource.clearCart();
  }
}
```

### 3. Implement User Repository Implementation

Create `lib/data/repositories/user_repository_impl.dart`:

```dart
import 'package:intellicart/domain/entities/user.dart';
import 'package:intellicart/domain/repositories/user_repository.dart';
import 'package:intellicart/data/datasources/user_firebase_data_source.dart';
import 'package:intellicart/data/models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserFirebaseDataSource dataSource;

  UserRepositoryImpl({required this.dataSource});

  @override
  Future<User> getCurrentUser() async {
    final userModel = await dataSource.getCurrentUser();
    return userModel.toEntity();
  }

  @override
  Future<User> updateUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    final updatedModel = await dataSource.updateUser(userModel);
    return updatedModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    return await dataSource.signOut();
  }
}
```

## Design Considerations

### 1. Data Model Conversion
The repository implementations handle the conversion between domain entities and data models. This maintains a clean separation between the domain layer (which should be independent of data sources) and the data layer (which works with data models tailored for the specific data source).

### 2. Error Propagation
Errors from the data sources are propagated up through the repository layer to the use cases, which can then handle them appropriately.

### 3. Implementation of Repository Interfaces
Each repository implementation directly implements its corresponding repository interface, ensuring that all required methods are implemented.

### 4. Dependency Injection Ready
The repositories are designed to accept their data sources through the constructor, making them easy to inject and test.

## Verification

To verify this step is complete:

1. All repository implementation files should exist in `lib/data/repositories/`
2. Each implementation should correctly implement its corresponding repository interface
3. Data conversion between entities and models should be properly handled
4. Error handling should be appropriately propagated
5. All required methods from the interfaces should be implemented

## Implementation Checklist

- [ ] Implement ProductRepositoryImpl
- [ ] Implement CartRepositoryImpl
- [ ] Implement UserRepositoryImpl
- [ ] Add caching layer to repositories
- [ ] Implement data validation in repositories
- [ ] Add logging for debugging purposes
- [ ] Implement retry mechanisms for network failures
- [ ] Add batch operations support
- [ ] Implement data synchronization strategies
- [ ] Add comprehensive unit tests

## Code Quality Checks

1. All repository implementations should have proper documentation comments
2. Method implementations should correctly convert between entities and models
3. Error handling should be consistent with the overall application approach
4. The implementations should be focused and follow the single responsibility principle
5. Constructor parameters should be properly typed and named

## Next Steps

After completing this step, we can move on to creating the BLoC components that will manage the state of our application and coordinate between the presentation layer and the domain layer.