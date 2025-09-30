import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/data/models/product_model.dart';
import 'package:intellicart/domain/entities/product.dart';

void main() {
  group('ProductModel', () {
    test('can be created and converted to entity', () {
      final productModel = ProductModel(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(productModel.id, equals(1));
      expect(productModel.name, equals('Test Product'));
      expect(productModel.description, equals('Test Description'));
      expect(productModel.price, equals(99.99));
      expect(productModel.imageUrl, equals('https://example.com/image.jpg'));

      // Test copyWith
      final copiedProductModel = productModel.copyWith(
        name: 'Copied Product',
        price: 199.99,
      );

      expect(copiedProductModel.id, equals(1));
      expect(copiedProductModel.name, equals('Copied Product'));
      expect(copiedProductModel.price, equals(199.99));
      expect(copiedProductModel.imageUrl, equals('https://example.com/image.jpg'));

      // Test toEntity
      final productEntity = productModel.toEntity();
      expect(productEntity.id, equals(1));
      expect(productEntity.name, equals('Test Product'));
      expect(productEntity.description, equals('Test Description'));
      expect(productEntity.price, equals(99.99));
      expect(productEntity.imageUrl, equals('https://example.com/image.jpg'));

      // Test fromEntity
      final entity = Product(
        id: 2,
        name: 'Entity Product',
        description: 'Entity Description',
        price: 199.99,
        imageUrl: 'https://example.com/entity.jpg',
      );

      final productModelFromEntity = ProductModel.fromEntity(entity);
      expect(productModelFromEntity.id, equals(2));
      expect(productModelFromEntity.name, equals('Entity Product'));
      expect(productModelFromEntity.description, equals('Entity Description'));
      expect(productModelFromEntity.price, equals(199.99));
      expect(productModelFromEntity.imageUrl, equals('https://example.com/entity.jpg'));

      // Test equality
      final productModel2 = ProductModel(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(productModel, equals(productModel2));
    });

    test('toJson and fromJson work correctly', () {
      final productModel = ProductModel(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final json = productModel.toJson();
      expect(json['id'], equals(1));
      expect(json['name'], equals('Test Product'));
      expect(json['description'], equals('Test Description'));
      expect(json['price'], equals(99.99));
      expect(json['imageUrl'], equals('https://example.com/image.jpg'));

      final productModelFromJson = ProductModel.fromJson(json);
      expect(productModelFromJson.id, equals(1));
      expect(productModelFromJson.name, equals('Test Product'));
      expect(productModelFromJson.description, equals('Test Description'));
      expect(productModelFromJson.price, equals(99.99));
      expect(productModelFromJson.imageUrl, equals('https://example.com/image.jpg'));
    });
  });
}