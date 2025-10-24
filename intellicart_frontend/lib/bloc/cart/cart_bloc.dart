// lib/bloc/cart/cart_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart_frontend/data/models/cart_item.dart';
import 'package:intellicart_frontend/data/repositories/cart_repository.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final CartItem cartItem;

  AddToCart(this.cartItem);

  @override
  List<Object?> get props => [cartItem];
}

class UpdateQuantity extends CartEvent {
  final String productId;
  final int quantity;

  UpdateQuantity(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class RemoveFromCart extends CartEvent {
 final String productId;

  RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCart extends CartEvent {}

abstract class CartState extends Equatable {
  const CartState();
  
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItem> cartItems;
  
  const CartLoaded(this.cartItems);
  
  @override
  List<Object> get props => [cartItems];
}

class CartError extends CartState {
  final String message;
  
  const CartError(this.message);
  
  @override
  List<Object> get props => [message];
}

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc({required CartRepository cartRepository})
      : _cartRepository = cartRepository,
        super(const CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    
    // Load cart items when the bloc is initialized
    add(LoadCart());
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(const CartLoading());
    try {
      final cartItems = await _cartRepository.getCartItems();
      emit(CartLoaded(cartItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
 }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.updateOrAddCartItem(event.cartItem);
      final cartItems = await _cartRepository.getCartItems();
      emit(CartLoaded(cartItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.updateQuantity(event.productId, event.quantity);
      final cartItems = await _cartRepository.getCartItems();
      emit(CartLoaded(cartItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.removeFromCartByProductId(event.productId);
      final updatedCartItems = await _cartRepository.getCartItems();
      emit(CartLoaded(updatedCartItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.clearCart();
      emit(const CartLoaded([]));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}