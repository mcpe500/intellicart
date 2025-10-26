import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/domain/entities/user.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/entities/order.dart';

void main() {
  group('User Model', () {
    test('User can be created and serialized', () {
      final user = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        role: 'buyer',
        createdAt: DateTime.now(),
      );

      expect(user.id, equals(1));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.role, equals('buyer'));

      // Test toJson
      final json = user.toJson();
      expect(json['id'], equals(1));
      expect(json['name'], equals('Test User'));
      expect(json['email'], equals('test@example.com'));
      expect(json['role'], equals('buyer'));

      // Test fromJson
      final userFromJson = User.fromJson(json);
      expect(userFromJson.id, equals(1));
      expect(userFromJson.name, equals('Test User'));
      expect(userFromJson.email, equals('test@example.com'));
      expect(userFromJson.role, equals('buyer'));

      // Test copyWith
      final copiedUser = user.copyWith(
        name: 'Updated User',
        email: 'updated@example.com',
      );

      expect(copiedUser.id, equals(1));
      expect(copiedUser.name, equals('Updated User'));
      expect(copiedUser.email, equals('updated@example.com'));
      expect(copiedUser.role, equals('buyer'));
      
      // Test equality
      final user2 = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        role: 'buyer',
        createdAt: DateTime.now(),
      );
      
      expect(user, equals(user2));
    });
  });

  group('Product Model', () {
    test('Product can be created and serialized', () {
      final product = Product(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        originalPrice: 109.99,
        imageUrl: 'https://example.com/image.jpg',
        sellerId: 1,
        reviews: [],
        createdAt: DateTime.now(),
      );

      expect(product.id, equals(1));
      expect(product.name, equals('Test Product'));
      expect(product.description, equals('Test Description'));
      expect(product.price, equals(99.99));
      expect(product.originalPrice, equals(109.99));
      expect(product.imageUrl, equals('https://example.com/image.jpg'));
      expect(product.sellerId, equals(1));
      expect(product.reviews, equals([]));

      // Test toJson
      final json = product.toJson();
      expect(json['id'], equals(1));
      expect(json['name'], equals('Test Product'));
      expect(json['description'], equals('Test Description'));
      expect(json['price'], equals(99.99));
      expect(json['originalPrice'], equals(109.99));
      expect(json['imageUrl'], equals('https://example.com/image.jpg'));
      expect(json['sellerId'], equals(1));

      // Test fromJson
      final productFromJson = Product.fromJson(json);
      expect(productFromJson.id, equals(1));
      expect(productFromJson.name, equals('Test Product'));
      expect(productFromJson.description, equals('Test Description'));
      expect(productFromJson.price, equals(99.99));
      expect(productFromJson.originalPrice, equals(109.99));
      expect(productFromJson.imageUrl, equals('https://example.com/image.jpg'));
      expect(productFromJson.sellerId, equals(1));

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

      // Test equality
      final product2 = Product(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        originalPrice: 109.99,
        imageUrl: 'https://example.com/image.jpg',
        sellerId: 1,
        reviews: [],
        createdAt: DateTime.now(),
      );
      
      expect(product, equals(product2));
    });
  });

  group('Order Model', () {
    test('Order can be created and serialized', () {
      final order = Order(
        id: 1,
        productId: 1,
        buyerId: 2,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      expect(order.id, equals(1));
      expect(order.productId, equals(1));
      expect(order.buyerId, equals(2));
      expect(order.status, equals('pending'));

      // Test toJson
      final json = order.toJson();
      expect(json['id'], equals(1));
      expect(json['productId'], equals(1));
      expect(json['buyerId'], equals(2));
      expect(json['status'], equals('pending'));

      // Test fromJson
      final orderFromJson = Order.fromJson(json);
      expect(orderFromJson.id, equals(1));
      expect(orderFromJson.productId, equals(1));
      expect(orderFromJson.buyerId, equals(2));
      expect(orderFromJson.status, equals('pending'));

      // Test copyWith
      final copiedOrder = order.copyWith(
        status: 'shipped',
      );

      expect(copiedOrder.id, equals(1));
      expect(copiedOrder.productId, equals(1));
      expect(copiedOrder.buyerId, equals(2));
      expect(copiedOrder.status, equals('shipped'));
      
      // Test equality
      final order2 = Order(
        id: 1,
        productId: 1,
        buyerId: 2,
        status: 'pending',
        createdAt: DateTime.now(),
      );
      
      expect(order, equals(order2));
    });
  });
}