import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';
import 'package:intellicart/domain/usecases/add_item_to_cart.dart';
import 'package:intellicart/domain/usecases/clear_cart.dart';
import 'package:intellicart/domain/usecases/get_cart_items.dart';
import 'package:intellicart/domain/usecases/get_cart_total.dart';
import 'package:intellicart/domain/usecases/remove_item_from_cart.dart';
import 'package:intellicart/domain/usecases/update_cart_item.dart';
import 'package:intellicart/presentation/bloc/cart/cart_event.dart';
import 'package:intellicart/presentation/bloc/cart/cart_state.dart';

/// BLoC for managing cart state.
///
/// This BLoC handles all cart-related events and manages the state
/// of the shopping cart in the application.
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartItems _getCartItems;
  final AddItemToCart _addItemToCart;
  final UpdateCartItem _updateCartItem;
  final RemoveItemFromCart _removeItemFromCart;
  final ClearCart _clearCart;
  final GetCartTotal _getCartTotal;

  /// Creates a new cart BLoC.
  CartBloc({
    required GetCartItems getCartItems,
    required AddItemToCart addItemToCart,
    required UpdateCartItem updateCartItem,
    required RemoveItemFromCart removeItemFromCart,
    required ClearCart clearCart,
    required GetCartTotal getCartTotal,
  })  : _getCartItems = getCartItems,
        _addItemToCart = addItemToCart,
        _updateCartItem = updateCartItem,
        _removeItemFromCart = removeItemFromCart,
        _clearCart = clearCart,
        _getCartTotal = getCartTotal,
        super(CartInitial()) {
    on<LoadCartItems>(_onLoadCartItems);
    on<AddItemToCartEvent>(_onAddItemToCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<RemoveItemFromCartEvent>(_onRemoveItemFromCart);
    on<ClearCartEvent>(_onClearCart);
  }

  /// Handles the LoadCartItems event.
  Future<void> _onLoadCartItems(
    LoadCartItems event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final items = await _getCartItems();
      final total = await _getCartTotal();
      emit(CartLoaded(items: items, total: total));
    } on AppException catch (e) {
      emit(CartError(e.toString()));
    } catch (e) {
      emit(CartError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the AddItemToCartEvent.
  Future<void> _onAddItemToCart(
    AddItemToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final newItem = await _addItemToCart(event.product, event.quantity);
      
      // Get current state
      final currentState = state;
      List<CartItem> currentItems = [];
      double currentTotal = 0.0;
      
      if (currentState is CartLoaded) {
        currentItems = List.from(currentState.items);
        currentTotal = currentState.total;
      } else {
        // If not loaded, fetch current items and total
        currentItems = await _getCartItems();
        currentTotal = await _getCartTotal();
      }
      
      // Check if item already exists in cart
      final index = currentItems.indexWhere((item) => item.product.id == newItem.product.id);
      if (index != -1) {
        // Update existing item
        currentItems[index] = newItem;
      } else {
        // Add new item
        currentItems.add(newItem);
      }
      
      // Update total
      final newTotal = currentTotal + (newItem.product.price * newItem.quantity);
      
      emit(CartLoaded(items: currentItems, total: newTotal));
    } on AppException catch (e) {
      emit(CartError(e.toString()));
    } catch (e) {
      emit(CartError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the UpdateCartItemEvent.
  Future<void> _onUpdateCartItem(
    UpdateCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final updatedItem = await _updateCartItem(event.item);
      
      // Get current state
      final currentState = state;
      List<CartItem> currentItems = [];
      double currentTotal = 0.0;
      
      if (currentState is CartLoaded) {
        currentItems = List.from(currentState.items);
        currentTotal = currentState.total;
      } else {
        // If not loaded, fetch current items and total
        currentItems = await _getCartItems();
        currentTotal = await _getCartTotal();
      }
      
      // Update item in list
      final index = currentItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        // Calculate the difference in total price
        final oldItemTotal = currentItems[index].totalPrice;
        final newItemTotal = updatedItem.totalPrice;
        final totalDifference = newItemTotal - oldItemTotal;
        
        currentItems[index] = updatedItem;
        final newTotal = currentTotal + totalDifference;
        
        emit(CartLoaded(items: currentItems, total: newTotal));
      }
    } on AppException catch (e) {
      emit(CartError(e.toString()));
    } catch (e) {
      emit(CartError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the RemoveItemFromCartEvent.
  Future<void> _onRemoveItemFromCart(
    RemoveItemFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _removeItemFromCart(event.itemId);
      
      // Get current state
      final currentState = state;
      List<CartItem> currentItems = [];
      double currentTotal = 0.0;
      
      if (currentState is CartLoaded) {
        currentItems = List.from(currentState.items);
        currentTotal = currentState.total;
      } else {
        // If not loaded, fetch current items and total
        currentItems = await _getCartItems();
        currentTotal = await _getCartTotal();
      }
      
      // Remove item from list and update total
      final removedItem = currentItems.firstWhere((item) => item.id == event.itemId);
      currentItems.removeWhere((item) => item.id == event.itemId);
      final newTotal = currentTotal - removedItem.totalPrice;
      
      emit(CartLoaded(items: currentItems, total: newTotal));
    } on AppException catch (e) {
      emit(CartError(e.toString()));
    } catch (e) {
      emit(CartError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handles the ClearCartEvent.
  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _clearCart();
      emit(const CartLoaded(items: [], total: 0.0));
    } on AppException catch (e) {
      emit(CartError(e.toString()));
    } catch (e) {
      emit(CartError('An unexpected error occurred: ${e.toString()}'));
    }
  }
}