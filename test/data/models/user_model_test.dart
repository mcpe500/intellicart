import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/data/models/user_model.dart';
import 'package:intellicart/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    test('can be created and converted to entity', () {
      final userModel = UserModel(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        photoUrl: 'https://example.com/avatar.jpg',
      );

      expect(userModel.id, equals(1));
      expect(userModel.email, equals('test@example.com'));
      expect(userModel.name, equals('Test User'));
      expect(userModel.photoUrl, equals('https://example.com/avatar.jpg'));

      // Test copyWith
      final copiedUserModel = userModel.copyWith(
        name: 'Copied User',
      );

      expect(copiedUserModel.id, equals(1));
      expect(copiedUserModel.email, equals('test@example.com'));
      expect(copiedUserModel.name, equals('Copied User'));
      expect(copiedUserModel.photoUrl, equals('https://example.com/avatar.jpg'));

      // Test toEntity
      final userEntity = userModel.toEntity();
      expect(userEntity.id, equals(1));
      expect(userEntity.email, equals('test@example.com'));
      expect(userEntity.name, equals('Test User'));
      expect(userEntity.photoUrl, equals('https://example.com/avatar.jpg'));

      // Test fromEntity
      final entity = User(
        id: 2,
        email: 'entity@example.com',
        name: 'Entity User',
        photoUrl: 'https://example.com/entity.jpg',
      );

      final userModelFromEntity = UserModel.fromEntity(entity);
      expect(userModelFromEntity.id, equals(2));
      expect(userModelFromEntity.email, equals('entity@example.com'));
      expect(userModelFromEntity.name, equals('Entity User'));
      expect(userModelFromEntity.photoUrl, equals('https://example.com/entity.jpg'));

      // Test equality
      final userModel2 = UserModel(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        photoUrl: 'https://example.com/avatar.jpg',
      );

      expect(userModel, equals(userModel2));
    });

    test('toJson and fromJson work correctly', () {
      final userModel = UserModel(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        photoUrl: 'https://example.com/avatar.jpg',
      );

      final json = userModel.toJson();
      expect(json['id'], equals(1));
      expect(json['email'], equals('test@example.com'));
      expect(json['name'], equals('Test User'));
      expect(json['photoUrl'], equals('https://example.com/avatar.jpg'));

      final userModelFromJson = UserModel.fromJson(json);
      expect(userModelFromJson.id, equals(1));
      expect(userModelFromJson.email, equals('test@example.com'));
      expect(userModelFromJson.name, equals('Test User'));
      expect(userModelFromJson.photoUrl, equals('https://example.com/avatar.jpg'));
    });
  });
}