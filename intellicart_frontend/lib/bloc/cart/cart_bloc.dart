import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart_frontend/data/models/cart_item.dart';
// import 'package:intellicart_frontend/services/database_service.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartStateInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<ClearCart>(_onClearCart);
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(const CartStateLoading());
    try {
      // TODO: Load cart items from SQLite
      await Future.delayed(const Duration(seconds: 1)); // Simulate DB call
      emit(const CartStateLoaded([]));
    } catch (e) {
      emit(CartStateError(e.toString()));
    }
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      // TODO: Add item to SQLite
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate DB call
      
      if (state is CartStateLoaded) {
        final items = List<CartItem>.from((state as CartStateLoaded).items);
        final existingIndex = items.indexWhere((item) => item.productId == event.item.productId);
        
        if (existingIndex >= 0) {
          items[existingIndex] = items[existingIndex].copyWith(
            quantity: items[existingIndex].quantity + event.item.quantity,
          );
        } else {
          items.add(event.item);
        }
        
        emit(CartStateLoaded(items));
      }
    } catch (e) {
      emit(CartStateError(e.toString()));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) async {
    try {
      // TODO: Remove item from SQLite
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate DB call
      
      if (state is CartStateLoaded) {
        final items = List<CartItem>.from((state as CartStateLoaded).items);
        items.removeWhere((item) => item.id == event.itemId);
        emit(CartStateLoaded(items));
      }
    } catch (e) {
      emit(CartStateError(e.toString()));
    }
  }

  void _onUpdateCartItem(UpdateCartItem event, Emitter<CartState> emit) async {
    try {
      // TODO: Update item in SQLite
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate DB call
      
      if (state is CartStateLoaded) {
        final items = List<CartItem>.from((state as CartStateLoaded).items);
        final index = items.indexWhere((item) => item.id == event.item.id);
        
        if (index >= 0) {
          items[index] = event.item;
          emit(CartStateLoaded(items));
        }
      }
    } catch (e) {
      emit(CartStateError(e.toString()));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      // TODO: Clear cart in SQLite
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate DB call
      emit(const CartStateLoaded([]));
    } catch (e) {
      emit(CartStateError(e.toString()));
    }
  }
}