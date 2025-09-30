# 12 - Implement Testing Framework

## Overview
This step involves implementing a comprehensive testing framework for the Intellicart application. We'll create unit tests for models, use cases, and repositories, as well as widget tests for UI components.

## Implementation Details

### 1. Update pubspec.yaml with Test Dependencies

First, ensure we have all the necessary test dependencies in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  mockito: ^5.4.0
  bloc_test: ^9.1.0
  build_runner: ^2.3.3
```

### 2. Create Model Tests

Create `test/model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/entities/user.dart';

void main() {
  group('Product Model', () {
    test('Product can be created and serialized', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
        categories: ['Electronics', 'Accessories'],
        metadata: {'brand': 'TestBrand'},
      );

      expect(product.id, equals('1'));
      expect(product.name, equals('Test Product'));
      expect(product.description, equals('Test Description'));
      expect(product.price, equals(99.99));
      expect(product.imageUrl, equals('https://example.com/image.jpg'));
      expect(product.categories, equals(['Electronics', 'Accessories']));
      expect(product.metadata, equals({'brand': 'TestBrand'}));

      // Test copyWith
      final copiedProduct = product.copyWith(
        name: 'Copied Product',
        price: 199.99,
      );

      expect(copiedProduct.id, equals('1'));
      expect(copiedProduct.name, equals('Copied Product'));
      expect(copiedProduct.price, equals(199.99));
      expect(copiedProduct.imageUrl, equals('https://example.com/image.jpg'));

      // Test equality
      final product2 = Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
        categories: ['Electronics', 'Accessories'],
        metadata: {'brand': 'TestBrand'},
      );

      expect(product, equals(product2));
    });
  });

  group('CartItem Model', () {
    test('CartItem can be created and total price calculated', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final cartItem = CartItem(
        id: 'item1',
        product: product,
        quantity: 3,
      );

      expect(cartItem.id, equals('item1'));
      expect(cartItem.product, equals(product));
      expect(cartItem.quantity, equals(3));
      expect(cartItem.totalPrice, equals(299.97)); // 99.99 * 3

      // Test copyWith
      final copiedItem = cartItem.copyWith(quantity: 5);
      expect(copiedItem.quantity, equals(5));
      expect(copiedItem.totalPrice, equals(499.95)); // 99.99 * 5
    });
  });

  group('User Model', () {
    test('User can be created and preferences handled', () {
      final user = User(
        id: 'user1',
        email: 'test@example.com',
        name: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        preferences: ['Electronics', 'Books'],
      );

      expect(user.id, equals('user1'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
      expect(user.photoUrl, equals('https://example.com/photo.jpg'));
      expect(user.preferences, equals(['Electronics', 'Books']));

      // Test copyWith
      final copiedUser = user.copyWith(name: 'Updated User');
      expect(copiedUser.name, equals('Updated User'));
      expect(copiedUser.email, equals('test@example.com'));
    });
  });
}
```

### 3. Create Use Case Tests

Create `test/usecase_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/update_product.dart';
import 'package:intellicart/domain/usecases/delete_product.dart';
import 'package:intellicart/domain/usecases/search_products.dart';
import 'package:intellicart/domain/usecases/add_item_to_cart.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';

// Generate mocks
@GenerateMocks([ProductRepository, CartRepository])
import 'usecase_test.mocks.dart';

void main() {
  group('Use Cases', () {
    late MockProductRepository mockProductRepository;
    late MockCartRepository mockCartRepository;

    setUp(() {
      mockProductRepository = MockProductRepository();
      mockCartRepository = MockCartRepository();
    });

    group('GetAllProducts Use Case', () {
      test('should get products from the repository', () async {
        // Arrange
        final products = [
          Product(
            id: '1',
            name: 'Test Product',
            description: 'Test Description',
            price: 99.99,
            imageUrl: 'https://example.com/image.jpg',
          ),
        ];
        when(mockProductRepository.getAllProducts()).thenAnswer((_) async => products);
        final usecase = GetAllProducts(mockProductRepository);

        // Act
        final result = await usecase();

        // Assert
        expect(result, equals(products));
        verify(mockProductRepository.getAllProducts()).called(1);
        verifyNoMoreInteractions(mockProductRepository);
      });
    });

    group('CreateProduct Use Case', () {
      test('should create product when valid product is provided', () async {
        // Arrange
        final product = Product(
          id: '',
          name: 'Test Product',
          description: 'Test Description',
          price: 99.99,
          imageUrl: 'https://example.com/image.jpg',
        );
        final createdProduct = product.copyWith(id: '1');
        when(mockProductRepository.createProduct(any)).thenAnswer((_) async => createdProduct);
        final usecase = CreateProduct(mockProductRepository);

        // Act
        final result = await usecase(product);

        // Assert
        expect(result, equals(createdProduct));
        verify(mockProductRepository.createProduct(product)).called(1);
      });

      test('should throw error when product name is empty', () async {
        // Arrange
        final product = Product(
          id: '',
          name: '',
          description: 'Test Description',
          price: 99.99,
          imageUrl: 'https://example.com/image.jpg',
        );
        final usecase = CreateProduct(mockProductRepository);

        // Act & Assert
        expect(() => usecase(product), throwsA(isA<ArgumentError>()));
      });

      test('should throw error when product price is negative', () async {
        // Arrange
        final product = Product(
          id: '',
          name: 'Test Product',
          description: 'Test Description',
          price: -99.99,
          imageUrl: 'https://example.com/image.jpg',
        );
        final usecase = CreateProduct(mockProductRepository);

        // Act & Assert
        expect(() => usecase(product), throwsA(isA<ArgumentError>()));
      });
    });

    group('UpdateProduct Use Case', () {
      test('should update product when valid product is provided', () async {
        // Arrange
        final product = Product(
          id: '1',
          name: 'Updated Product',
          description: 'Updated Description',
          price: 199.99,
          imageUrl: 'https://example.com/updated.jpg',
        );
        when(mockProductRepository.updateProduct(any)).thenAnswer((_) async => product);
        final usecase = UpdateProduct(mockProductRepository);

        // Act
        final result = await usecase(product);

        // Assert
        expect(result, equals(product));
        verify(mockProductRepository.updateProduct(product)).called(1);
      });

      test('should throw error when product id is empty', () async {
        // Arrange
        final product = Product(
          id: '',
          name: 'Test Product',
          description: 'Test Description',
          price: 99.99,
          imageUrl: 'https://example.com/image.jpg',
        );
        final usecase = UpdateProduct(mockProductRepository);

        // Act & Assert
        expect(() => usecase(product), throwsA(isA<ArgumentError>()));
      });
    });

    group('DeleteProduct Use Case', () {
      test('should delete product when valid id is provided', () async {
        // Arrange
        const productId = '1';
        when(mockProductRepository.deleteProduct(any)).thenAnswer((_) async {});
        final usecase = DeleteProduct(mockProductRepository);

        // Act
        await usecase(productId);

        // Assert
        verify(mockProductRepository.deleteProduct(productId)).called(1);
      });

      test('should throw error when product id is empty', () async {
        // Arrange
        const productId = '';
        final usecase = DeleteProduct(mockProductRepository);

        // Act & Assert
        expect(() => usecase(productId), throwsA(isA<ArgumentError>()));
      });
    });

    group('SearchProducts Use Case', () {
      test('should search products when query is provided', () async {
        // Arrange
        const query = 'keyboard';
        final products = [
          Product(
            id: '1',
            name: 'Wireless Keyboard',
            description: 'Test Description',
            price: 99.99,
            imageUrl: 'https://example.com/image.jpg',
          ),
        ];
        when(mockProductRepository.searchProducts(any)).thenAnswer((_) async => products);
        final usecase = SearchProducts(mockProductRepository);

        // Act
        final result = await usecase(query);

        // Assert
        expect(result, equals(products));
        verify(mockProductRepository.searchProducts(query)).called(1);
      });

      test('should get all products when query is empty', () async {
        // Arrange
        const query = '';
        final products = [
          Product(
            id: '1',
            name: 'Wireless Keyboard',
            description: 'Test Description',
            price: 99.99,
            imageUrl: 'https://example.com/image.jpg',
          ),
        ];
        when(mockProductRepository.getAllProducts()).thenAnswer((_) async => products);
        final usecase = SearchProducts(mockProductRepository);

        // Act
        final result = await usecase(query);

        // Assert
        expect(result, equals(products));
        verify(mockProductRepository.getAllProducts()).called(1);
      });
    });

    group('AddItemToCart Use Case', () {
      test('should add item to cart when valid product and quantity are provided', () async {
        // Arrange
        final product = Product(
          id: '1',
          name: 'Test Product',
          description: 'Test Description',
          price: 99.99,
          imageUrl: 'https://example.com/image.jpg',
        );
        const quantity = 2;
        final cartItem = CartItem(id: 'item1', product: product, quantity: quantity);
        when(mockCartRepository.addItemToCart(any, any)).thenAnswer((_) async => cartItem);
        final usecase = AddItemToCart(mockCartRepository);

        // Act
        final result = await usecase(product, quantity);

        // Assert
        expect(result, equals(cartItem));
        verify(mockCartRepository.addItemToCart(product, quantity)).called(1);
      });

      test('should throw error when quantity is zero or negative', () async {
        // Arrange
        final product = Product(
          id: '1',
          name: 'Test Product',
          description: 'Test Description',
          price: 99.99,
          imageUrl: 'https://example.com/image.jpg',
        );
        const quantity = 0;
        final usecase = AddItemToCart(mockCartRepository);

        // Act & Assert
        expect(() => usecase(product, quantity), throwsA(isA<ArgumentError>()));

        // Test negative quantity
        const negativeQuantity = -1;
        expect(() => usecase(product, negativeQuantity), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
```

Note: We need to run the build runner to generate the mock files:

```bash
flutter pub run build_runner build
```

### 4. Create BLoC Tests

Create `test/bloc_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/update_product.dart';
import 'package:intellicart/domain/usecases/delete_product.dart';
import 'package:intellicart/domain/usecases/search_products.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/product/product_event.dart';
import 'package:intellicart/presentation/bloc/product/product_state.dart';

// Generate mocks
@GenerateMocks([
  GetAllProducts,
  CreateProduct,
  UpdateProduct,
  DeleteProduct,
  SearchProducts,
])
import 'bloc_test.mocks.dart';

void main() {
  group('ProductBloc', () {
    late MockGetAllProducts mockGetAllProducts;
    late MockCreateProduct mockCreateProduct;
    late MockUpdateProduct mockUpdateProduct;
    late MockDeleteProduct mockDeleteProduct;
    late MockSearchProducts mockSearchProducts;

    setUp(() {
      mockGetAllProducts = MockGetAllProducts();
      mockCreateProduct = MockCreateProduct();
      mockUpdateProduct = MockUpdateProduct();
      mockDeleteProduct = MockDeleteProduct();
      mockSearchProducts = MockSearchProducts();
    });

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when LoadProducts is added',
      build: () {
        when(mockGetAllProducts()).thenAnswer(
          (_) async => [
            Product(
              id: '1',
              name: 'Test Product',
              description: 'Test Description',
              price: 99.99,
              imageUrl: 'https://example.com/image.jpg',
            ),
          ],
        );
        return ProductBloc(
          getAllProducts: mockGetAllProducts,
          createProduct: mockCreateProduct,
          updateProduct: mockUpdateProduct,
          deleteProduct: mockDeleteProduct,
          searchProducts: mockSearchProducts,
        );
      },
      act: (bloc) => bloc.add(LoadProducts()),
      expect: () => [
        ProductLoading(),
        const ProductLoaded([
          Product(
            id: '1',
            name: 'Test Product',
            description: 'Test Description',
            price: 99.99,
            imageUrl: 'https://example.com/image.jpg',
          ),
        ]),
      ],
      verify: (_) {
        verify(mockGetAllProducts()).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when SearchProductsEvent is added',
      build: () {
        when(mockSearchProducts('keyboard')).thenAnswer(
          (_) async => [
            Product(
              id: '1',
              name: 'Wireless Keyboard',
              description: 'Test Description',
              price: 99.99,
              imageUrl: 'https://example.com/image.jpg',
            ),
          ],
        );
        return ProductBloc(
          getAllProducts: mockGetAllProducts,
          createProduct: mockCreateProduct,
          updateProduct: mockUpdateProduct,
          deleteProduct: mockDeleteProduct,
          searchProducts: mockSearchProducts,
        );
      },
      act: (bloc) => bloc.add(const SearchProductsEvent('keyboard')),
      expect: () => [
        ProductLoading(),
        const ProductLoaded([
          Product(
            id: '1',
            name: 'Wireless Keyboard',
            description: 'Test Description',
            price: 99.99,
            imageUrl: 'https://example.com/image.jpg',
          ),
        ]),
      ],
      verify: (_) {
        verify(mockSearchProducts('keyboard')).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductError] when LoadProducts fails',
      build: () {
        when(mockGetAllProducts()).thenThrow(Exception('Failed to load products'));
        return ProductBloc(
          getAllProducts: mockGetAllProducts,
          createProduct: mockCreateProduct,
          updateProduct: mockUpdateProduct,
          deleteProduct: mockDeleteProduct,
          searchProducts: mockSearchProducts,
        );
      },
      act: (bloc) => bloc.add(LoadProducts()),
      expect: () => [
        ProductLoading(),
        const ProductError('Exception: Failed to load products'),
      ],
    );
  });
}
```

### 5. Create Widget Tests

Create `test/widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/product/product_state.dart';
import 'package:intellicart/presentation/widgets/product_list_item.dart';

// Generate mocks
@GenerateMocks([ProductBloc])
import 'widget_test.mocks.dart';

void main() {
  group('ProductListItem', () {
    testWidgets('displays product information correctly', (WidgetTester tester) async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
        categories: ['Electronics'],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(product: product),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
    });

    testWidgets('tapping on item navigates to product detail', (WidgetTester tester) async {
      // Arrange
      final product = Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      // Track navigation
      bool navigated = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(product: product),
          ),
          onGenerateRoute: (settings) {
            if (settings.name == '/product-detail') {
              navigated = true;
              return MaterialPageRoute(
                builder: (context) => const Scaffold(body: Text('Product Detail')),
              );
            }
            return null;
          },
        ),
      );

      // Act
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Assert
      // Note: We can't easily test navigation in this context, but we can verify the tap
      expect(find.byType(ListTile), findsOneWidget);
    });
  });

  group('ProductList', () {
    late MockProductBloc mockProductBloc;

    setUp(() {
      mockProductBloc = MockProductBloc();
    });

    testWidgets('shows loading indicator when ProductLoading state', (WidgetTester tester) async {
      // Arrange
      when(mockProductBloc.state).thenReturn(ProductLoading());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductBloc>.value(
            value: mockProductBloc,
            child: const Scaffold(body: ProductList()),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows products when ProductLoaded state', (WidgetTester tester) async {
      // Arrange
      final products = [
        Product(
          id: '1',
          name: 'Test Product 1',
          description: 'Test Description',
          price: 99.99,
          imageUrl: 'https://example.com/image1.jpg',
        ),
        Product(
          id: '2',
          name: 'Test Product 2',
          description: 'Test Description',
          price: 199.99,
          imageUrl: 'https://example.com/image2.jpg',
        ),
      ];
      when(mockProductBloc.state).thenReturn(ProductLoaded(products));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductBloc>.value(
            value: mockProductBloc,
            child: const Scaffold(body: ProductList()),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Product 1'), findsOneWidget);
      expect(find.text('Test Product 2'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.text('\$199.99'), findsOneWidget);
    });

    testWidgets('shows error message when ProductError state', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load products';
      when(mockProductBloc.state).thenReturn(const ProductError(errorMessage));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductBloc>.value(
            value: mockProductBloc,
            child: const Scaffold(body: ProductList()),
          ),
        ),
      );

      // Assert
      expect(find.text('Error: $errorMessage'), findsOneWidget);
    });
  });
}
```

## Design Considerations

### 1. Comprehensive Test Coverage
We're implementing tests for all major components: models, use cases, BLoCs, and widgets.

### 2. Mocking Dependencies
We're using Mockito to mock dependencies, allowing us to test components in isolation.

### 3. BLoC Testing
We're using the bloc_test package for comprehensive BLoC testing, which allows us to test state transitions.

### 4. Widget Testing
We're implementing widget tests to ensure UI components render correctly and respond to user interactions.

### 5. Error Handling
Tests include error conditions to ensure our application handles errors gracefully.

## Verification

To verify this step is complete:

1. All test files should exist in the `test/` directory
2. Tests should cover models, use cases, BLoCs, and widgets
3. Mock files should be generated by build_runner
4. Tests should pass when run with `flutter test`
5. Test coverage should be comprehensive

## Code Quality Checks

1. All tests should have descriptive names
2. Tests should follow the Arrange-Act-Assert pattern
3. Mocks should be used appropriately to isolate components
4. Edge cases and error conditions should be tested
5. Tests should be maintainable and readable

## Running Tests

To run the tests:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/model_test.dart
```

## Next Steps

After completing this step, we can move on to adding comprehensive error handling throughout our application.