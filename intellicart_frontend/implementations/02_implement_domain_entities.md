# 02 - Implement Core Domain Entities (Product, CartItem, User)

## Overview
This step involves implementing the core domain entities as defined in the technical specification. These entities represent the business objects in our application and are fundamental to the clean architecture.

## Implementation Details

### 1. Create the Product Entity

Create `lib/domain/entities/product.dart`:

```dart
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> categories;
  final Map<String, dynamic> metadata;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.categories = const [],
    this.metadata = const {},
  });

  /// Creates a copy of this product with the given fields replaced
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? categories,
    Map<String, dynamic>? metadata,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, name, description, price, imageUrl, categories, metadata];
}
```

### 2. Create the CartItem Entity

Create `lib/domain/entities/cart_item.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/product.dart';

class CartItem extends Equatable {
  final String id;
  final Product product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  /// Creates a copy of this cart item with the given fields replaced
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity];
}
```

### 3. Create the User Entity

Create `lib/domain/entities/user.dart`:

```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final List<String> preferences;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.preferences = const [],
  });

  /// Creates a copy of this user with the given fields replaced
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    List<String>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoUrl, preferences];
}
```

### 4. Create Equatable Mixin for Consistency

Since we're using the Equatable package for value equality, we need to ensure all entities properly implement it. The implementation above already does this.

## Verification

To verify this step is complete:

1. All three entity files should exist in `lib/domain/entities/`
2. Each entity should properly implement the Equatable mixin
3. Each entity should have appropriate properties as defined in the specification
4. Each entity should have a `copyWith` method for creating modified copies
5. Each entity should properly define `props` for Equatable

## Implementation Checklist

- [ ] Create Product entity with all required fields
- [ ] Implement copyWith method for Product entity
- [ ] Implement Equatable for Product entity
- [ ] Create CartItem entity with all required fields
- [ ] Implement copyWith method for CartItem entity
- [ ] Implement Equatable for CartItem entity
- [ ] Create User entity with all required fields
- [ ] Implement copyWith method for User entity
- [ ] Implement Equatable for User entity
- [ ] Add validation logic to entities
- [ ] Implement custom equality comparison logic
- [ ] Add serialization methods for entities
- [ ] Add comprehensive documentation for all entities
- [ ] Add unit tests for entity methods

## Code Quality Checks

1. All entities should be immutable (use `final` for all fields)
2. All entities should have proper documentation comments
3. All entities should follow Dart naming conventions
4. The `copyWith` methods should handle all fields appropriately
5. The `props` getter should include all fields that affect equality

## Next Steps

After completing this step, we can move on to creating the repository interfaces which define how our application will interact with data sources.