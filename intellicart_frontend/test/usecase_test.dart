import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/update_product.dart';
import 'package:intellicart/domain/usecases/delete_product.dart';
import 'package:intellicart/domain/usecases/sync_products.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([ProductRepository])
import 'usecase_test.mocks.dart';

void main() {
  group('Use Cases', () {
    late MockProductRepository mockRepository;

    setUp(() {
      mockRepository = MockProductRepository();
    });

    test('GetAllProducts should call repository.getAllProducts', () async {
      // Arrange
      final products = [
        Product(
          id: '1',
          name: 'Test Product',
          description: 'Test Description',
          price: '99.99',
          imageUrl: 'https://example.com/image.jpg',
          sellerId: '1',
          reviews: [],
        ),
      ];
      when(mockRepository.getAllProducts()).thenAnswer((_) async => products);
      final usecase = GetAllProducts(mockRepository);

      // Act
      final result = await usecase();

      // Assert
      expect(result, equals(products));
      verify(mockRepository.getAllProducts()).called(1);
    });

    test('CreateProduct should call repository.createProduct', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: '99.99',
        imageUrl: 'https://example.com/image.jpg',
        sellerId: '1',
        reviews: [],
      );
      when(mockRepository.createProduct(any)).thenAnswer((_) async => product);
      final usecase = CreateProduct(mockRepository);

      // Act
      final result = await usecase(product);

      // Assert
      expect(result, equals(product));
      verify(mockRepository.createProduct(product)).called(1);
    });

    test('UpdateProduct should call repository.updateProduct', () async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: '99.99',
        imageUrl: 'https://example.com/image.jpg',
        sellerId: '1',
        reviews: [],
      );
      when(mockRepository.updateProduct(any)).thenAnswer((_) async => product);
      final usecase = UpdateProduct(mockRepository);

      // Act
      final result = await usecase(product);

      // Assert
      expect(result, equals(product));
      verify(mockRepository.updateProduct(product)).called(1);
    });

    test('DeleteProduct should call repository.deleteProduct', () async {
      // Arrange
      const productId = 1;
      when(mockRepository.deleteProduct(any)).thenAnswer((_) async {});
      final usecase = DeleteProduct(mockRepository);

      // Act
      await usecase(productId);

      // Assert
      verify(mockRepository.deleteProduct(productId)).called(1);
    });

    test('SyncProducts should call repository.syncProducts', () async {
      // Arrange
      final products = [
        Product(
          id: '1',
          name: 'Test Product',
          description: 'Test Description',
          price: '99.99',
          imageUrl: 'https://example.com/image.jpg',
          sellerId: '1',
          reviews: [],
        ),
      ];
      when(mockRepository.syncProducts(any)).thenAnswer((_) async {});
      final usecase = SyncProducts(mockRepository);

      // Act
      await usecase(products);

      // Assert
      verify(mockRepository.syncProducts(products)).called(1);
    });
  });
}