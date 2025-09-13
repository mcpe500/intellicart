import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/entities/product.dart';

void main() {
  group('CartItem', () {
    test('can be created and total price calculated', () {
      final product = Product(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final cartItem = CartItem(
        id: 1,
        product: product,
        quantity: 2,
      );

      expect(cartItem.id, equals(1));
      expect(cartItem.product, equals(product));
      expect(cartItem.quantity, equals(2));
      expect(cartItem.totalPrice, equals(199.98));

      // Test copyWith
      final copiedCartItem = cartItem.copyWith(
        quantity: 3,
      );

      expect(copiedCartItem.id, equals(1));
      expect(copiedCartItem.product, equals(product));
      expect(copiedCartItem.quantity, equals(3));
      expect(copiedCartItem.totalPrice, closeTo(299.97, 0.001));

      // Test equality
      final cartItem2 = CartItem(
        id: 1,
        product: product,
        quantity: 2,
      );

      expect(cartItem, equals(cartItem2));
    });

    test('toJson and fromJson work correctly', () {
      final product = Product(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final cartItem = CartItem(
        id: 1,
        product: product,
        quantity: 2,
      );

      final json = cartItem.toJson();
      expect(json['id'], equals(1));
      expect(json['quantity'], equals(2));
      expect(json['product']['id'], equals(1));
      expect(json['product']['name'], equals('Test Product'));

      final cartItemFromJson = CartItem.fromJson(json);
      expect(cartItemFromJson.id, equals(1));
      expect(cartItemFromJson.quantity, equals(2));
      expect(cartItemFromJson.product.id, equals(1));
      expect(cartItemFromJson.product.name, equals('Test Product'));
    });
  });
}