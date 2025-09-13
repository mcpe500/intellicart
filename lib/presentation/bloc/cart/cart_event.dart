import 'package:equatable/equatable.dart';
import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/entities/product.dart';

/// Base class for all cart events.
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

/// Event to load all cart items.
class LoadCartItems extends CartEvent {}

/// Event to add an item to the cart.
class AddItemToCartEvent extends CartEvent {
  final Product product;
  final int quantity;

  const AddItemToCartEvent(this.product, this.quantity);

  @override
  List<Object> get props => [product, quantity];
}

/// Event to update a cart item.
class UpdateCartItemEvent extends CartEvent {
  final CartItem item;

  const UpdateCartItemEvent(this.item);

  @override
  List<Object> get props => [item];
}

/// Event to remove an item from the cart.
class RemoveItemFromCartEvent extends CartEvent {
  final int itemId;

  const RemoveItemFromCartEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}

/// Event to clear the cart.
class ClearCartEvent extends CartEvent {}