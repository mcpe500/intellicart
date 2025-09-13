import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/domain/entities/product.dart';

void main() {
  group('Product', () {
    test('can be created and serialized', () {
      final product = Product(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(product.id, equals(1));
      expect(product.name, equals('Test Product'));
      expect(product.description, equals('Test Description'));
      expect(product.price, equals(99.99));
      expect(product.imageUrl, equals('https://example.com/image.jpg'));

      // Test copyWith
      final copiedProduct = product.copyWith(
        name: 'Copied Product',
        price: 199.99,
      );

      expect(copiedProduct.id, equals(1));
      expect(copiedProduct.name, equals('Copied Product'));
      expect(copiedProduct.price, equals(199.99));
      expect(copiedProduct.imageUrl, equals('https://example.com/image.jpg'));

      // Test equality
      final product2 = Product(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(product, equals(product2));
    });

    test('toJson and fromJson work correctly', () {
      final product = Product(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final json = product.toJson();
      expect(json['id'], equals(1));
      expect(json['name'], equals('Test Product'));
      expect(json['description'], equals('Test Description'));
      expect(json['price'], equals(99.99));
      expect(json['imageUrl'], equals('https://example.com/image.jpg'));

      final productFromJson = Product.fromJson(json);
      expect(productFromJson.id, equals(1));
      expect(productFromJson.name, equals('Test Product'));
      expect(productFromJson.description, equals('Test Description'));
      expect(productFromJson.price, equals(99.99));
      expect(productFromJson.imageUrl, equals('https://example.com/image.jpg'));
    });
  });
}