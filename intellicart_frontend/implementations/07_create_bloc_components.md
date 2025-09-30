# 07 - Create BLoC Components

## Overview
This step involves creating the BLoC (Business Logic Components) that will manage the state of our application. BLoCs will handle events from the UI, execute use cases, and emit states that the UI can react to. We'll create BLoCs for product management, cart management, user management, and AI interactions.

## Implementation Details

### 1. Create Product BLoC Event Classes

Create `lib/presentation/bloc/product/product_event.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  @override
  List<Object?> get props => [];
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateProductEvent extends ProductEvent {
  final Product product;

  const CreateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final Product product;

  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}
```

### 2. Create Product BLoC State Classes

Create `lib/presentation/bloc/product/product_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### 3. Create Product BLoC

Create `lib/presentation/bloc/product/product_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/update_product.dart';
import 'package:intellicart/domain/usecases/delete_product.dart';
import 'package:intellicart/domain/usecases/search_products.dart';
import 'package:intellicart/presentation/bloc/product/product_event.dart';
import 'package:intellicart/presentation/bloc/product/product_state.dart';

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
    } catch (e) {
      emit(ProductError(e.toString()));
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
    } catch (e) {
      emit(ProductError(e.toString()));
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
    } catch (e) {
      emit(ProductError(e.toString()));
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
    } catch (e) {
      emit(ProductError(e.toString()));
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
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
```

### 4. Create Cart BLoC Event Classes

Create `lib/presentation/bloc/cart/cart_event.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartItems extends CartEvent {
  @override
  List<Object?> get props => [];
}

class AddItemToCartEvent extends CartEvent {
  final Product product;
  final int quantity;

  const AddItemToCartEvent(this.product, this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}

class UpdateCartItemEvent extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateCartItemEvent(this.itemId, this.quantity);

  @override
  List<Object?> get props => [itemId, quantity];
}

class RemoveItemFromCartEvent extends CartEvent {
  final String itemId;

  const RemoveItemFromCartEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class ClearCartEvent extends CartEvent {
  @override
  List<Object?> get props => [];
}
```

### 5. Create Cart BLoC State Classes

Create `lib/presentation/bloc/cart/cart_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/cart_item.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;

  const CartLoaded(this.items);

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items, totalPrice, totalItems];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### 6. Create Cart BLoC

Create `lib/presentation/bloc/cart/cart_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/usecases/add_item_to_cart.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';
import 'package:intellicart/presentation/bloc/cart/cart_event.dart';
import 'package:intellicart/presentation/bloc/cart/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;
  final AddItemToCart addItemToCart;

  CartBloc({
    required this.cartRepository,
    required this.addItemToCart,
  }) : super(CartInitial()) {
    on<LoadCartItems>(_onLoadCartItems);
    on<AddItemToCartEvent>(_onAddItemToCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<RemoveItemFromCartEvent>(_onRemoveItemFromCart);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onLoadCartItems(
    LoadCartItems event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final items = await cartRepository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddItemToCart(
    AddItemToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await addItemToCart(event.product, event.quantity);
      // Reload cart items after addition
      final items = await cartRepository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateCartItem(
    UpdateCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      // This would require a use case for updating cart items
      // For now, we'll reload the cart
      final items = await cartRepository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveItemFromCart(
    RemoveItemFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await cartRepository.removeItemFromCart(event.itemId);
      // Reload cart items after removal
      final items = await cartRepository.getCartItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await cartRepository.clearCart();
      emit(const CartLoaded([]));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
```

### 7. Create AI Interaction BLoC Event Classes

Create `lib/presentation/bloc/ai/ai_interaction_event.dart`:

```dart
import 'package:equatable/equatable.dart';

abstract class AIInteractionEvent extends Equatable {
  const AIInteractionEvent();

  @override
  List<Object?> get props => [];
}

class ProcessNaturalLanguageCommandEvent extends AIInteractionEvent {
  final String command;

  const ProcessNaturalLanguageCommandEvent(this.command);

  @override
  List<Object?> get props => [command];
}
```

### 8. Create AI Interaction BLoC State Classes

Create `lib/presentation/bloc/ai/ai_interaction_state.dart`:

```dart
import 'package:equatable/equatable.dart';

abstract class AIInteractionState extends Equatable {
  const AIInteractionState();

  @override
  List<Object?> get props => [];
}

class AIInteractionInitial extends AIInteractionState {}

class AIInteractionProcessing extends AIInteractionState {}

class AIInteractionSuccess extends AIInteractionState {
  final String message;

  const AIInteractionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AIInteractionError extends AIInteractionState {
  final String message;

  const AIInteractionError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### 9. Create AI Interaction BLoC

Create `lib/presentation/bloc/ai/ai_interaction_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/usecases/process_natural_language_command.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_event.dart';
import 'package:intellicart/presentation/bloc/ai/ai_interaction_state.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/cart/cart_bloc.dart';

class AIInteractionBloc extends Bloc<AIInteractionEvent, AIInteractionState> {
  final ProcessNaturalLanguageCommand processCommand;
  final ProductBloc productBloc;
  final CartBloc cartBloc;

  AIInteractionBloc({
    required this.processCommand,
    required this.productBloc,
    required this.cartBloc,
  }) : super(AIInteractionInitial()) {
    on<ProcessNaturalLanguageCommandEvent>(_onProcessNaturalLanguageCommand);
  }

  Future<void> _onProcessNaturalLanguageCommand(
    ProcessNaturalLanguageCommandEvent event,
    Emitter<AIInteractionState> emit,
  ) async {
    emit(AIInteractionProcessing());
    try {
      final action = await processCommand(event.command);
      
      // Execute the action based on the parsed command
      switch (action.type) {
        case ActionType.ADD_TO_CART:
          // Find product and add to cart
          productBloc.add(SearchProductsEvent(action.productName!));
          // After search completes, we would add to cart
          // This would require listening to ProductBloc state changes
          emit(const AIInteractionSuccess('Added item to your cart'));
          break;
        case ActionType.SEARCH:
          productBloc.add(SearchProductsEvent(action.query!));
          emit(AIInteractionSuccess('Searching for ${action.query}'));
          break;
        case ActionType.CREATE_PRODUCT:
          // Handle product creation
          emit(const AIInteractionSuccess('Creating product'));
          break;
        // ... other action types
        default:
          emit(const AIInteractionSuccess('I\'m not sure how to help with that request.'));
      }
    } catch (e) {
      emit(AIInteractionError(e.toString()));
    }
  }
}
```

Note: We're referencing `ActionType` which will be implemented in the AI interaction system step.

## Design Considerations

### 1. Event-Driven Architecture
Each BLoC follows an event-driven architecture where events trigger state changes. This makes the code predictable and testable.

### 2. State Management
BLoCs manage state transitions and emit new states that the UI can react to. This provides a clear separation between business logic and UI.

### 3. Use Case Integration
BLoCs use the use cases we implemented earlier to execute business logic, maintaining a clean separation of concerns.

### 4. Error Handling
Each BLoC properly handles errors and emits appropriate error states that the UI can display to the user.

### 5. Asynchronous Operations
All BLoC operations are asynchronous, allowing for non-blocking UI updates and proper handling of network requests.

## Verification

To verify this step is complete:

1. All BLoC event, state, and bloc files should exist in `lib/presentation/bloc/`
2. Each BLoC should properly handle its corresponding events
3. Each BLoC should emit appropriate states during processing
4. Error handling should be implemented in all BLoCs
5. BLoCs should use use cases rather than directly accessing repositories

## Implementation Checklist

- [ ] Create Product BLoC event classes
- [ ] Create Product BLoC state classes
- [ ] Create Product BLoC
- [ ] Create Cart BLoC event classes
- [ ] Create Cart BLoC state classes
- [ ] Create Cart BLoC
- [ ] Create AI Interaction BLoC event classes
- [ ] Create AI Interaction BLoC state classes
- [ ] Create AI Interaction BLoC
- [ ] Add comprehensive error handling to all BLoCs
- [ ] Implement state persistence for BLoCs
- [ ] Add logging for debugging purposes
- [ ] Implement retry mechanisms for failed operations
- [ ] Add performance optimizations
- [ ] Implement comprehensive unit tests

## Code Quality Checks

1. All BLoC components should have proper documentation comments
2. Event and state classes should properly implement Equatable
3. BLoC methods should be focused and follow the single responsibility principle
4. Error handling should be consistent across all BLoCs
5. State transitions should be logical and predictable

## Next Steps

After completing this step, we can move on to implementing the AI interaction system which will enable natural language processing for user commands.