import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/cart_item.dart';

/// Base class for all cart states.
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

/// Initial state for the cart BLoC.
class CartInitial extends CartState {}

/// State when cart items are being loaded.
class CartLoading extends CartState {}

/// State when cart items have been successfully loaded.
class CartLoaded extends CartState {
  final List<CartItem> items;
  final double total;

  const CartLoaded({required this.items, required this.total});

  @override
  List<Object> get props => [items, total];
}

/// State when there is an error loading cart items.
class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}