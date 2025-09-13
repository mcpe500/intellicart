# 05 - Setup Firebase Data Sources

## Overview
This step involves setting up the Firebase data sources that will serve as the concrete implementations for our data layer. We'll implement data sources for Firestore (products and cart), Authentication (user management), and prepare for Storage and Cloud Messaging.

## Implementation Details

### 1. Setup Firebase Core Initialization

First, ensure Firebase is properly initialized in the app. Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intellicart/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intellicart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
```

### 2. Implement Product Firestore Data Source

Create `lib/data/datasources/product_firestore_data_source.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intellicart/data/models/product_model.dart';
import 'package:intellicart/core/errors/exceptions.dart';

class ProductFirestoreDataSource {
  final FirebaseFirestore firestore;

  ProductFirestoreDataSource({required this.firestore});

  CollectionReference get productsCollection => firestore.collection('products');

  Future<List<ProductModel>> getAllProducts() async {
    final querySnapshot = await productsCollection.get();
    return querySnapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final docSnapshot = await productsCollection.doc(id).get();
    if (!docSnapshot.exists) {
      throw ProductNotFoundException('Product with id $id not found');
    }
    return ProductModel.fromJson(docSnapshot.data() as Map<String, dynamic>)
        .copyWith(id: docSnapshot.id);
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final querySnapshot = await productsCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return querySnapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id))
        .toList();
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final docRef = await productsCollection.add(product.toJson());
    final docSnapshot = await docRef.get();
    return ProductModel.fromJson(docSnapshot.data() as Map<String, dynamic>)
        .copyWith(id: docSnapshot.id);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    await productsCollection.doc(product.id).update(product.toJson());
    return product;
  }

  Future<void> deleteProduct(String id) async {
    await productsCollection.doc(id).delete();
  }
}
```

### 3. Implement User Firebase Data Source

Create `lib/data/datasources/user_firebase_data_source.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intellicart/data/models/user_model.dart';
import 'package:intellicart/core/errors/exceptions.dart';

class UserFirebaseDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  UserFirebaseDataSource({required this.auth, required this.firestore});

  CollectionReference get usersCollection => firestore.collection('users');

  Future<UserModel> getCurrentUser() async {
    final firebaseUser = auth.currentUser;
    if (firebaseUser == null) {
      throw UserNotAuthenticatedException('No authenticated user found');
    }

    final docSnapshot = await usersCollection.doc(firebaseUser.uid).get();
    if (!docSnapshot.exists) {
      // Create user document if it doesn't exist
      final userModel = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'Anonymous User',
        photoUrl: firebaseUser.photoURL,
      );
      await usersCollection.doc(firebaseUser.uid).set(userModel.toJson());
      return userModel;
    }

    return UserModel.fromJson(docSnapshot.data() as Map<String, dynamic>)
        .copyWith(id: docSnapshot.id);
  }

  Future<UserModel> updateUser(UserModel user) async {
    await usersCollection.doc(user.id).update(user.toJson());
    return user;
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
```

### 4. Implement Cart Firestore Data Source

Create `lib/data/datasources/cart_firestore_data_source.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intellicart/data/models/cart_item_model.dart';
import 'package:intellicart/data/models/product_model.dart';

class CartFirestoreDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  CartFirestoreDataSource({required this.auth, required this.firestore});

  CollectionReference get cartItemsCollection {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return firestore.collection('carts').doc(user.uid).collection('items');
  }

  Future<List<CartItemModel>> getCartItems() async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final querySnapshot = await cartItemsCollection.get();
    final cartItems = <CartItemModel>[];

    for (var doc in querySnapshot.docs) {
      final cartItemJson = doc.data() as Map<String, dynamic>;
      
      // Fetch the product details
      final productDoc = await firestore
          .collection('products')
          .doc(cartItemJson['productId'])
          .get();
      
      if (productDoc.exists) {
        final productModel = ProductModel.fromJson(
                productDoc.data() as Map<String, dynamic>)
            .copyWith(id: productDoc.id);
        
        cartItems.add(
          CartItemModel.fromJson(cartItemJson)
              .copyWith(id: doc.id, product: productModel),
        );
      }
    }

    return cartItems;
  }

  Future<CartItemModel> addItemToCart(
      ProductModel product, int quantity) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Check if item already exists in cart
    final querySnapshot = await cartItemsCollection
        .where('productId', isEqualTo: product.id)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update existing item
      final existingDoc = querySnapshot.docs.first;
      final existingCartItem = CartItemModel.fromJson(
              existingDoc.data() as Map<String, dynamic>)
          .copyWith(id: existingDoc.id);

      final updatedQuantity = existingCartItem.quantity + quantity;
      final updatedCartItem = existingCartItem.copyWith(quantity: updatedQuantity);

      await cartItemsCollection
          .doc(existingCartItem.id)
          .update(updatedCartItem.toJson());

      return updatedCartItem;
    } else {
      // Add new item
      final newCartItem = CartItemModel(
        id: '',
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      );

      final docRef = await cartItemsCollection.add(newCartItem.toJson());
      final docSnapshot = await docRef.get();

      return newCartItem.copyWith(
        id: docSnapshot.id,
      );
    }
  }

  Future<CartItemModel> updateCartItem(CartItemModel item) async {
    await cartItemsCollection.doc(item.id).update(item.toJson());
    return item;
  }

  Future<void> removeItemFromCart(String itemId) async {
    await cartItemsCollection.doc(itemId).delete();
  }

  Future<void> clearCart() async {
    final querySnapshot = await cartItemsCollection.get();
    final batch = firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
```

### 5. Create Custom Exceptions

Create `lib/core/errors/exceptions.dart`:

```dart
class ProductNotFoundException implements Exception {
  final String message;

  ProductNotFoundException(this.message);

  @override
  String toString() => 'ProductNotFoundException: $message';
}

class UserNotAuthenticatedException implements Exception {
  final String message;

  UserNotAuthenticatedException(this.message);

  @override
  String toString() => 'UserNotAuthenticatedException: $message';
}
```

## Design Considerations

### 1. Firebase Integration
We're using the official Firebase plugins for Flutter:
- `cloud_firestore` for database operations
- `firebase_auth` for authentication

### 2. Data Modeling
The data sources work with data models rather than domain entities, maintaining a clear separation between the data layer and domain layer.

### 3. Error Handling
Custom exceptions are defined for specific error cases, allowing for more precise error handling in the application.

### 4. Authentication Integration
The cart data source integrates with Firebase Authentication to associate cart items with specific users.

### 5. Efficient Queries
Firestore queries are optimized with proper indexing and filtering to ensure good performance.

## Verification

To verify this step is complete:

1. All data source files should exist in `lib/data/datasources/`
2. Firebase should be properly initialized in the main application
3. Each data source should correctly interact with its respective Firebase service
4. Custom exceptions should be defined and used appropriately
5. Data sources should work with data models rather than domain entities

## Implementation Checklist

- [ ] Setup Firebase core initialization
- [ ] Implement ProductFirestoreDataSource
- [ ] Implement UserFirebaseDataSource
- [ ] Implement CartFirestoreDataSource
- [ ] Create custom exception classes
- [ ] Add offline persistence support
- [ ] Implement data synchronization strategies
- [ ] Add advanced querying capabilities
- [ ] Implement batch operations for better performance
- [ ] Add data validation in data sources
- [ ] Implement caching mechanisms
- [ ] Add comprehensive error handling

## Code Quality Checks

1. All data sources should have proper documentation comments
2. Method names should be descriptive and follow Dart conventions
3. Error handling should be comprehensive
4. Firebase references should be properly managed
5. Data conversion between models and Firestore should be correctly implemented

## Next Steps

After completing this step, we can move on to implementing the repository implementations that will use these data sources to fulfill the repository interfaces.