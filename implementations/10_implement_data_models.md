# 10 - Implement Data Models

## Overview
This step involves implementing the data models that will be used to transfer data between the different layers of our application. These models will handle serialization/deserialization to and from JSON format for storage in Firebase Firestore.

## Implementation Details

### 1. Implement Product Model

Create `lib/data/models/product_model.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/product.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> categories;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.categories = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
      categories: List<String>.from(json['categories'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categories': categories,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categories: categories,
      metadata: metadata,
    );
  }

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      imageUrl: entity.imageUrl,
      categories: entity.categories,
      metadata: entity.metadata,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? categories,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        categories,
        metadata,
        createdAt,
        updatedAt,
      ];
}
```

### 2. Implement Cart Item Model

Create `lib/data/models/cart_item_model.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/data/models/product_model.dart';

class CartItemModel extends Equatable {
  final String id;
  final ProductModel product;
  final int quantity;
  final DateTime addedAt;

  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  CartItem toEntity() {
    return CartItem(
      id: id,
      product: product.toEntity(),
      quantity: quantity,
    );
  }

  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      id: entity.id,
      product: ProductModel.fromEntity(entity.product),
      quantity: entity.quantity,
      addedAt: DateTime.now(),
    );
  }

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity, addedAt];
}
```

### 3. Implement User Model

Create `lib/data/models/user_model.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/user.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final List<String> preferences;
  final DateTime createdAt;
  final DateTime lastActive;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.preferences = const [],
    required this.createdAt,
    required this.lastActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      preferences: List<String>.from(json['preferences'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActive: DateTime.parse(json['lastActive'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      preferences: preferences,
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      photoUrl: entity.photoUrl,
      preferences: entity.preferences,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    List<String>? preferences,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        preferences,
        createdAt,
        lastActive,
      ];
}
```

## Design Considerations

### 1. Serialization/Deserialization
Each data model implements `toJson()` and `fromJson()` methods to handle serialization and deserialization to and from JSON format, which is required for storage in Firebase Firestore.

### 2. Entity Conversion
Data models have methods to convert to and from domain entities, maintaining a clean separation between the data layer and domain layer.

### 3. Immutability
All data models are immutable (using `final` for all fields) and provide `copyWith()` methods for creating modified copies.

### 4. Equatable Implementation
All data models implement the Equatable mixin for value equality comparisons, which is useful for testing and state management.

### 5. DateTime Handling
DateTime fields are properly serialized to ISO 8601 strings for storage and parsed back when deserializing.

## Verification

To verify this step is complete:

1. All data model files should exist in `lib/data/models/`
2. Each model should properly implement serialization/deserialization methods
3. Each model should have appropriate conversion methods to and from domain entities
4. Each model should properly implement the Equatable mixin
5. All required fields should be handled correctly, including optional fields

## Code Quality Checks

1. All data models should have proper documentation comments
2. Serialization/deserialization methods should handle all fields correctly
3. Error handling should be implemented for parsing operations
4. The models should be immutable and provide copyWith methods
5. DateTime fields should be properly handled during serialization

### **Implementation Checklist for Step 10: Implement Data Models**

[ ] Create `ProductModel` with `fromJson`, `toJson`, `toEntity`, and `fromEntity` methods
[ ] Create `CartItemModel` with `fromJson`, `toJson`, `toEntity`, and `fromEntity` methods
[ ] Create `UserModel` with `fromJson`, `toJson`, `toEntity`, and `fromEntity` methods
[ ] Ensure all models properly implement the `Equatable` mixin
[ ] Implement `copyWith` methods for all data models
[ ] Add comprehensive error handling in `fromJson` constructors (e.g., type casting, null checks)
[ ] Verify DateTime fields are correctly serialized to/from ISO 8601 strings
[ ] Implement unit tests for serialization/deserialization of all models
[ ] Implement unit tests for conversion between models and entities
[ ] Ensure immutability (all fields are `final`)
[ ] Add documentation comments for all classes, methods, and properties

## Next Steps

After completing this step, we can move on to setting up dependency injection which will allow us to manage object creation and dependencies throughout our application.