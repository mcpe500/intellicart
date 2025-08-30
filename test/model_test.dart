import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/models/product.dart';

void main() {
  group('Product Model', () {
    test('Product can be created and serialized', () {
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

      // Test toJson
      final json = product.toJson();
      expect(json['id'], equals(1));
      expect(json['name'], equals('Test Product'));
      expect(json['description'], equals('Test Description'));
      expect(json['price'], equals(99.99));
      expect(json['imageUrl'], equals('https://example.com/image.jpg'));

      // Test fromJson
      final productFromJson = Product.fromJson(json);
      expect(productFromJson.id, equals(1));
      expect(productFromJson.name, equals('Test Product'));
      expect(productFromJson.description, equals('Test Description'));
      expect(productFromJson.price, equals(99.99));
      expect(productFromJson.imageUrl, equals('https://example.com/image.jpg'));

      // Test copyWith
      final copiedProduct = product.copyWith(
        name: 'Copied Product',
        description: 'Copied Description',
        price: 199.99,
      );

      expect(copiedProduct.id, equals(1));
      expect(copiedProduct.name, equals('Copied Product'));
      expect(copiedProduct.description, equals('Copied Description'));
      expect(copiedProduct.price, equals(199.99));
      expect(copiedProduct.imageUrl, equals('https://example.com/image.jpg'));
    });
  });
}