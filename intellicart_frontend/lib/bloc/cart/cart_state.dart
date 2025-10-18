part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartStateInitial extends CartState {
  const CartStateInitial();
}

class CartStateLoading extends CartState {
  const CartStateLoading();
}

class CartStateLoaded extends CartState {
  final List<CartItem> items;

  const CartStateLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class CartStateError extends CartState {
  final String message;

  const CartStateError(this.message);

  @override
  List<Object> get props => [message];
}
