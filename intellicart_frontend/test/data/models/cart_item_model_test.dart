import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/data/models/cart_item_model.dart';
import 'package:intellicart/data/models/product_model.dart';
import 'package:intellicart/domain/entities/cart_item.dart';

void main() {
  group('CartItemModel', () {
    test('can be created and converted to entity', () {
      final productModel = ProductModel(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final cartItemModel = CartItemModel(
        id: 1,
        product: productModel,
        quantity: 2,
      );

      expect(cartItemModel.id, equals(1));
      expect(cartItemModel.product, equals(productModel));
      expect(cartItemModel.quantity, equals(2));

      // Test copyWith
      final copiedCartItemModel = cartItemModel.copyWith(
        quantity: 3,
      );

      expect(copiedCartItemModel.id, equals(1));
      expect(copiedCartItemModel.product, equals(productModel));
      expect(copiedCartItemModel.quantity, equals(3));

      // Test toEntity
      final cartItemEntity = cartItemModel.toEntity();
      expect(cartItemEntity.id, equals(1));
      expect(cartItemEntity.product.id, equals(1));
      expect(cartItemEntity.product.name, equals('Test Product'));
      expect(cartItemEntity.quantity, equals(2));

      // Test fromEntity
      final product = productModel.toEntity();
      final entity = CartItem(
        id: 2,
        product: product,
        quantity: 3,
      );

      final cartItemModelFromEntity = CartItemModel.fromEntity(entity);
      expect(cartItemModelFromEntity.id, equals(2));
      expect(cartItemModelFromEntity.product.id, equals(1));
      expect(cartItemModelFromEntity.product.name, equals('Test Product'));
      expect(cartItemModelFromEntity.quantity, equals(3));

      // Test equality
      final productModel2 = ProductModel(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final cartItemModel2 = CartItemModel(
        id: 1,
        product: productModel2,
        quantity: 2,
      );

      expect(cartItemModel, equals(cartItemModel2));
    });

    test('toJson and fromJson work correctly', () {
      final productModel = ProductModel(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final cartItemModel = CartItemModel(
        id: 1,
        product: productModel,
        quantity: 2,
      );

      final json = cartItemModel.toJson();
      expect(json['id'], equals(1));
      expect(json['quantity'], equals(2));
      expect(json['product']['id'], equals(1));
      expect(json['product']['name'], equals('Test Product'));

      final cartItemModelFromJson = CartItemModel.fromJson(json);
      expect(cartItemModelFromJson.id, equals(1));
      expect(cartItemModelFromJson.quantity, equals(2));
      expect(cartItemModelFromJson.product.id, equals(1));
      expect(cartItemModelFromJson.product.name, equals('Test Product'));
    });
  });
}