# 08 - Implement AI Interaction System

## Overview
This step involves implementing the AI interaction system that enables users to interact with the app through natural language commands. This system will parse user input and convert it into actionable commands for the application.

## Implementation Details

### 1. Create AI Action Types

Create `lib/presentation/ai/action_type.dart`:

```dart
enum ActionType {
  ADD_TO_CART,
  REMOVE_FROM_CART,
  SEARCH,
  CREATE_PRODUCT,
  UPDATE_PRODUCT,
  DELETE_PRODUCT,
  VIEW_CART,
  CHECKOUT,
}
```

### 2. Create AI Action Model

Create `lib/presentation/ai/ai_action.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:intellicart/presentation/ai/action_type.dart';

class AIAction extends Equatable {
  final ActionType type;
  final String? productName;
  final int quantity;
  final String? query;
  final double? maxPrice;
  final SortOrder? sortOrder;

  const AIAction({
    required this.type,
    this.productName,
    this.quantity = 1,
    this.query,
    this.maxPrice,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [type, productName, quantity, query, maxPrice, sortOrder];
}

enum SortOrder {
  RELEVANCE,
  PRICE_LOW_TO_HIGH,
  PRICE_HIGH_TO_LOW,
  NAME_A_TO_Z,
}
```

### 3. Implement Natural Language Processor

Create `lib/presentation/ai/natural_language_processor.dart`:

```dart
import 'package:intellicart/presentation/ai/ai_action.dart';
import 'package:intellicart/presentation/ai/action_type.dart';
import 'package:intellicart/presentation/ai/sort_order.dart';

class NaturalLanguageProcessor {
  /// Parses a natural language command into an actionable AIAction
  Future<AIAction> parseCommand(String command) async {
    // Normalize the command
    final normalizedCommand = command.toLowerCase().trim();

    // Handle complex compound commands
    if (normalizedCommand.contains(' and ') &&
        (normalizedCommand.contains('add') || normalizedCommand.contains('find'))) {
      return _parseCompoundCommand(normalizedCommand);
    }

    // Handle conditional commands
    if (normalizedCommand.contains('under') || normalizedCommand.contains('below')) {
      return _parseConditionalCommand(normalizedCommand);
    }

    // Handle sorting commands
    if (normalizedCommand.contains('sort') || normalizedCommand.contains('order')) {
      return _parseSortingCommand(normalizedCommand);
    }

    // Handle standard commands
    if (normalizedCommand.contains('add') && normalizedCommand.contains('cart')) {
      return _parseAddToCartCommand(normalizedCommand);
    }

    if (normalizedCommand.contains('search') || normalizedCommand.contains('find')) {
      return _parseSearchCommand(normalizedCommand);
    }

    if (normalizedCommand.contains('create') || normalizedCommand.contains('add product')) {
      return _parseCreateProductCommand(normalizedCommand);
    }

    // Default to search if no specific action is identified
    return AIAction(
      type: ActionType.SEARCH,
      query: command,
    );
  }

  /// Parses compound commands like "Add a keyboard and mouse to my cart"
  AIAction _parseCompoundCommand(String command) {
    // Split the command by "and"
    final parts = command.split(' and ');

    // For simplicity, we'll process the first part and note that there are more
    final firstPart = parts[0];

    // Determine action type based on first part
    if (firstPart.contains('add') && firstPart.contains('cart')) {
      final productName = _extractProductName(firstPart);
      return AIAction(
        type: ActionType.ADD_TO_CART,
        productName: productName,
      );
    }

    if (firstPart.contains('find') || firstPart.contains('search')) {
      final query = _extractSearchQuery(firstPart);
      return AIAction(
        type: ActionType.SEARCH,
        query: query,
      );
    }

    // Fallback
    return AIAction(
      type: ActionType.SEARCH,
      query: command,
    );
  }

  /// Parses conditional commands like "Find a keyboard under $30"
  AIAction _parseConditionalCommand(String command) {
    final productName = _extractProductName(command);
    double? maxPrice;

    // Extract price constraint
    final priceMatch = RegExp(r'(under|below)\s*\$?(\d+(?:\.\d+)?)').firstMatch(command);
    if (priceMatch != null) {
      maxPrice = double.parse(priceMatch.group(2)!);
    }

    return AIAction(
      type: ActionType.SEARCH,
      query: productName,
      maxPrice: maxPrice,
    );
  }

  /// Parses sorting commands like "Show me keyboards sorted by price"
  AIAction _parseSortingCommand(String command) {
    final query = _extractSearchQuery(command);
    SortOrder sortOrder = SortOrder.RELEVANCE;

    // Extract sorting preference
    if (command.contains('price')) {
      sortOrder = command.contains('low') || command.contains('cheap')
          ? SortOrder.PRICE_LOW_TO_HIGH
          : SortOrder.PRICE_HIGH_TO_LOW;
    } else if (command.contains('name')) {
      sortOrder = SortOrder.NAME_A_TO_Z;
    }

    return AIAction(
      type: ActionType.SEARCH,
      query: query,
      sortOrder: sortOrder,
    );
  }

  /// Parses commands like "Add a keyboard to my cart" or "Add 2 keyboards to cart"
  AIAction _parseAddToCartCommand(String command) {
    // Extract quantity (default to 1)
    int quantity = 1;
    final quantityMatch = RegExp(r'(\d+)').firstMatch(command);
    if (quantityMatch != null) {
      quantity = int.parse(quantityMatch.group(1)!);
    }

    // Extract product name (everything after "add" and before "to cart")
    String productName = '';
    final productMatch = RegExp(r'add\s+(?:\d+\s+)?(.+?)\s+to\s+cart').firstMatch(command);
    if (productMatch != null) {
      productName = productMatch.group(1)!.trim();
    } else {
      // Fallback: extract last word or phrase
      final words = command.split(' ');
      if (words.length > 1) {
        productName = words.sublist(1).join(' ');
      }
    }

    return AIAction(
      type: ActionType.ADD_TO_CART,
      productName: productName,
      quantity: quantity,
    );
  }

  /// Parses search commands like "Search for keyboards" or "Find keyboards"
  AIAction _parseSearchCommand(String command) {
    // Extract search query (everything after "search for" or "find")
    String query = command;
    if (command.contains('search for')) {
      query = command.substring(command.indexOf('search for') + 10).trim();
    } else if (command.contains('find')) {
      query = command.substring(command.indexOf('find') + 4).trim();
    }

    return AIAction(
      type: ActionType.SEARCH,
      query: query,
    );
  }

  /// Parses create product commands like "Create a new keyboard product"
  AIAction _parseCreateProductCommand(String command) {
    // Extract product name (everything after "create" or "add product")
    String productName = command;
    if (command.contains('create')) {
      productName = command.substring(command.indexOf('create') + 6).trim();
    } else if (command.contains('add product')) {
      productName = command.substring(command.indexOf('add product') + 11).trim();
    }

    // Remove common words like "a", "an", "the", "new", "product"
    final wordsToRemove = ['a', 'an', 'the', 'new', 'product'];
    final filteredWords = productName.split(' ')
        .where((word) => !wordsToRemove.contains(word))
        .toList();
    productName = filteredWords.join(' ');

    return AIAction(
      type: ActionType.CREATE_PRODUCT,
      productName: productName,
    );
  }

  String _extractProductName(String command) {
    // Simplified extraction - in a real implementation, this would be more robust
    if (command.contains('add')) {
      final match = RegExp(r'add\s+(?:\d+\s+)?(.+?)\s+(?:to\s+cart|to\s+my\s+cart)').firstMatch(command);
      if (match != null) {
        return match.group(1)!.trim();
      }
    }
    return command;
  }

  String _extractSearchQuery(String command) {
    if (command.contains('search for')) {
      return command.substring(command.indexOf('search for') + 10).trim();
    } else if (command.contains('find')) {
      return command.substring(command.indexOf('find') + 4).trim();
    }
    return command;
  }
}
```

### 4. Create Sort Order Enum

Create `lib/presentation/ai/sort_order.dart`:

```dart
enum SortOrder {
  RELEVANCE,
  PRICE_LOW_TO_HIGH,
  PRICE_HIGH_TO_LOW,
  NAME_A_TO_Z,
}
```

### 5. Implement AI Action Executor

Create `lib/presentation/ai/ai_action_executor.dart`:

```dart
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';
import 'package:intellicart/presentation/ai/ai_action.dart';
import 'package:intellicart/presentation/ai/action_type.dart';
import 'package:intellicart/presentation/ai/sort_order.dart';

class AIActionExecutor {
  final ProductRepository productRepository;
  final CartRepository cartRepository;

  AIActionExecutor({
    required this.productRepository,
    required this.cartRepository,
  });

  /// Executes an AI action and returns a result message
  Future<String> executeAction(AIAction action) async {
    switch (action.type) {
      case ActionType.ADD_TO_CART:
        return _executeAddToCart(action);
      case ActionType.SEARCH:
        return _executeSearch(action);
      case ActionType.CREATE_PRODUCT:
        return _executeCreateProduct(action);
      // ... other action types
      default:
        return 'I'm not sure how to help with that request.';
    }
  }

  Future<String> _executeAddToCart(AIAction action) async {
    try {
      // Search for the product
      final products = await productRepository.searchProducts(action.productName!);

      if (products.isEmpty) {
        return 'I couldn't find a product called "${action.productName}". Would you like to search for something else?';
      }

      // Use the first matching product
      final product = products.first;

      // Add to cart
      await cartRepository.addItemToCart(product, action.quantity);

      return 'Added ${action.quantity} ${product.name} to your cart.';
    } catch (e) {
      return 'Sorry, I encountered an error adding that item to your cart: ${e.toString()}';
    }
  }

  Future<String> _executeSearch(AIAction action) async {
    try {
      List<Product> products = await productRepository.searchProducts(action.query!);

      // Apply filters if specified
      if (action.maxPrice != null) {
        products = products.where((p) => p.price <= action.maxPrice!).toList();
      }

      // Apply sorting if specified
      switch (action.sortOrder) {
        case SortOrder.PRICE_LOW_TO_HIGH:
          products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case SortOrder.PRICE_HIGH_TO_LOW:
          products.sort((a, b) => b.price.compareTo(a.price));
          break;
        case SortOrder.NAME_A_TO_Z:
          products.sort((a, b) => a.name.compareTo(b.name));
          break;
        default:
          // Default sorting by relevance is handled by the search itself
          break;
      }

      if (products.isEmpty) {
        return 'I couldn't find any products matching "${action.query}".';
      }

      // For simplicity, we'll just return the count
      // In a real implementation, we might update the UI to show these products
      return 'I found ${products.length} products matching "${action.query}".';
    } catch (e) {
      return 'Sorry, I encountered an error searching for products: ${e.toString()}';
    }
  }

  Future<String> _executeCreateProduct(AIAction action) async {
    try {
      final product = Product(
        id: '', // Will be generated by the repository
        name: action.productName!,
        description: 'Product created via voice command',
        price: 0.0, // Default price
        imageUrl: '',
        categories: [],
      );

      await productRepository.createProduct(product);

      return 'I've created a new product called "${product.name}". You can edit its details now.';
    } catch (e) {
      return 'Sorry, I encountered an error creating the product: ${e.toString()}';
    }
  }
}
```

Note: In the AIActionExecutor, we're referencing the Product entity which should be imported. We also need to make sure all the necessary imports are in place.

## Design Considerations

### 1. Natural Language Processing
The NaturalLanguageProcessor uses regular expressions to parse common command patterns. In a production environment, this would likely be replaced with a more sophisticated NLP engine or machine learning model.

### 2. Extensibility
The system is designed to be extensible, with new action types and command patterns easily added.

### 3. Error Handling
The AIActionExecutor properly handles errors and provides user-friendly error messages.

### 4. Asynchronous Operations
All AI processing operations are asynchronous to prevent blocking the UI.

### 5. Separation of Concerns
The parsing logic is separated from the execution logic, making both easier to test and maintain.

## Verification

To verify this step is complete:

1. All AI-related files should exist in `lib/presentation/ai/`
2. The NaturalLanguageProcessor should correctly parse various command patterns
3. The AIActionExecutor should properly execute actions and handle errors
4. All necessary enums and models should be implemented
5. The system should integrate with the existing BLoC architecture

## Code Quality Checks

1. All AI components should have proper documentation comments
2. Regular expressions should be well-documented and tested
3. Error handling should be comprehensive and user-friendly
4. The code should be extensible for future enhancements
5. The parsing logic should handle edge cases appropriately

### **Implementation Checklist for Step 08: Implement AI Interaction System**

[ ] Create `ActionType` enum
[ ] Create `AIAction` model with Equatable
[ ] Create `SortOrder` enum
[ ] Implement `NaturalLanguageProcessor` class with comprehensive command parsing
[ ] Implement `AIActionExecutor` class to handle action execution
[ ] Add comprehensive error handling in `AIActionExecutor`
[ ] Ensure all necessary imports are in place (e.g., Product, repositories)
[ ] Add logging for debugging parsed commands and executed actions
[ ] Implement unit tests for `NaturalLanguageProcessor` (covering edge cases and various command patterns)
[ ] Implement unit tests for `AIActionExecutor`
[ ] Integrate the AI system with the existing `AIInteractionBloc`
[ ] Document all public methods and classes

## Next Steps

After completing this step, we can move on to developing the UI components that will provide the user interface for our application.