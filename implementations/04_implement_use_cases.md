# 04 - Implement Use Cases

## Overview
This step involves implementing the use cases that contain the business logic of the application. Use cases orchestrate the interactions between the presentation layer and the domain layer by using the repository interfaces.

## Implementation Details

### 1. Implement GetAllProducts Use Case

Create `lib/domain/usecases/get_all_products.dart`:

```dart
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<List<Product>> call() async {
    return await repository.getAllProducts();
  }
}
```

### 2. Implement CreateProduct Use Case

Create `lib/domain/usecases/create_product.dart`:

```dart
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<Product> call(Product product) async {
    // Business logic validation
    if (product.name.isEmpty) {
      throw ArgumentError('Product name cannot be empty');
    }
    if (product.price < 0) {
      throw ArgumentError('Product price must be positive');
    }
    return await repository.createProduct(product);
  }
}
```

### 3. Implement UpdateProduct Use Case

Create `lib/domain/usecases/update_product.dart`:

```dart
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Product> call(Product product) async {
    // Business logic validation
    if (product.id.isEmpty) {
      throw ArgumentError('Product ID cannot be empty');
    }
    if (product.name.isEmpty) {
      throw ArgumentError('Product name cannot be empty');
    }
    return await repository.updateProduct(product);
  }
}
```

### 4. Implement DeleteProduct Use Case

Create `lib/domain/usecases/delete_product.dart`:

```dart
import 'package:intellicart/domain/repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<void> call(String productId) async {
    if (productId.isEmpty) {
      throw ArgumentError('Product ID cannot be empty');
    }
    return await repository.deleteProduct(productId);
  }
}
```

### 5. Implement SearchProducts Use Case

Create `lib/domain/usecases/search_products.dart`:

```dart
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';

class SearchProducts {
  final ProductRepository repository;

  SearchProducts(this.repository);

  Future<List<Product>> call(String query) async {
    if (query.isEmpty) {
      return await repository.getAllProducts();
    }
    return await repository.searchProducts(query);
  }
}
```

### 6. Implement AddItemToCart Use Case

Create `lib/domain/usecases/add_item_to_cart.dart`:

```dart
import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';

class AddItemToCart {
  final CartRepository repository;

  AddItemToCart(this.repository);

  Future<CartItem> call(Product product, int quantity) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }
    return await repository.addItemToCart(product, quantity);
  }
}
```

### 7. Implement ProcessNaturalLanguageCommand Use Case

Create `lib/domain/usecases/process_natural_language_command.dart`:

```dart
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';
import 'package:intellicart/presentation/ai/natural_language_processor.dart';
import 'package:intellicart/presentation/ai/ai_action.dart';

class ProcessNaturalLanguageCommand {
  final NaturalLanguageProcessor processor;
  final ProductRepository productRepository;
  final CartRepository cartRepository;

  ProcessNaturalLanguageCommand({
    required this.processor,
    required this.productRepository,
    required this.cartRepository,
  });

  Future<AIAction> call(String command) async {
    if (command.isEmpty) {
      throw ArgumentError('Command cannot be empty');
    }
    return await processor.parseCommand(command);
  }
}
```

Note: We're referencing `NaturalLanguageProcessor` and `AIAction` which will be implemented later in the AI interaction system step.

## Design Considerations

### 1. Single Responsibility Principle
Each use case has a single, well-defined responsibility, making them easy to test and maintain.

### 2. Business Logic Validation
Use cases contain business logic validation before calling repository methods, ensuring data integrity.

### 3. Error Handling
Use cases throw appropriate exceptions when validation fails, allowing the presentation layer to handle errors gracefully.

### 4. Repository Abstraction
Use cases depend on repository interfaces rather than concrete implementations, following the dependency inversion principle.

### 5. Callable Classes
Use cases are implemented as callable classes (with a `call` method), allowing them to be used like functions while still being injectable and testable.

## Verification

To verify this step is complete:

1. All use case files should exist in `lib/domain/usecases/`
2. Each use case should have a single responsibility
3. Each use case should validate input parameters appropriately
4. Each use case should use repository interfaces rather than concrete implementations
5. Each use case should handle errors appropriately

## Implementation Checklist

- [ ] Implement GetAllProducts use case
- [ ] Implement CreateProduct use case
- [ ] Implement UpdateProduct use case
- [ ] Implement DeleteProduct use case
- [ ] Implement SearchProducts use case
- [ ] Implement AddItemToCart use case
- [ ] Implement ProcessNaturalLanguageCommand use case
- [ ] Add comprehensive validation to all use cases
- [ ] Implement caching strategies for better performance
- [ ] Add logging for debugging and monitoring
- [ ] Add retry mechanisms for network failures
- [ ] Implement batch operations for better efficiency
- [ ] Add comprehensive unit tests for all use cases

## Code Quality Checks

1. All use cases should have proper documentation comments
2. Method names should be descriptive and follow Dart conventions
3. Parameter names should be clear and consistent
4. Return types should be appropriately specified
5. Business logic validation should be comprehensive but not overly complex
6. Error messages should be clear and helpful

## Next Steps

After completing this step, we can move on to setting up the Firebase data sources which will provide the concrete implementations for our repository interfaces.