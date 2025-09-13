import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/domain/entities/user.dart';

void main() {
  group('User', () {
    test('can be created and serialized', () {
      final user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        photoUrl: 'https://example.com/avatar.jpg',
      );

      expect(user.id, equals(1));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
      expect(user.photoUrl, equals('https://example.com/avatar.jpg'));

      // Test copyWith
      final copiedUser = user.copyWith(
        name: 'Copied User',
      );

      expect(copiedUser.id, equals(1));
      expect(copiedUser.email, equals('test@example.com'));
      expect(copiedUser.name, equals('Copied User'));
      expect(copiedUser.photoUrl, equals('https://example.com/avatar.jpg'));

      // Test equality
      final user2 = User(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        photoUrl: 'https://example.com/avatar.jpg',
      );

      expect(user, equals(user2));
    });

    test('toJson and fromJson work correctly', () {
      final user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        photoUrl: 'https://example.com/avatar.jpg',
      );

      final json = user.toJson();
      expect(json['id'], equals(1));
      expect(json['email'], equals('test@example.com'));
      expect(json['name'], equals('Test User'));
      expect(json['photoUrl'], equals('https://example.com/avatar.jpg'));

      final userFromJson = User.fromJson(json);
      expect(userFromJson.id, equals(1));
      expect(userFromJson.email, equals('test@example.com'));
      expect(userFromJson.name, equals('Test User'));
      expect(userFromJson.photoUrl, equals('https://example.com/avatar.jpg'));
    });
  });
}