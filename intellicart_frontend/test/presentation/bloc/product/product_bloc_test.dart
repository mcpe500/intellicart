import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/delete_product.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/sync_products.dart';
import 'package:intellicart/domain/usecases/update_product.dart';
import 'package:intellicart/presentation/bloc/product/product_bloc.dart';
import 'package:intellicart/presentation/bloc/product/product_event.dart';
import 'package:intellicart/presentation/bloc/product/product_state.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([
  GetAllProducts,
  CreateProduct,
  UpdateProduct,
  DeleteProduct,
  SyncProducts,
])
import 'product_bloc_test.mocks.dart';

void main() {
  group('ProductBloc', () {
    late MockGetAllProducts mockGetAllProducts;
    late MockCreateProduct mockCreateProduct;
    late MockUpdateProduct mockUpdateProduct;
    late MockDeleteProduct mockDeleteProduct;
    late MockSyncProducts mockSyncProducts;
    late ProductBloc productBloc;

    setUp(() {
      mockGetAllProducts = MockGetAllProducts();
      mockCreateProduct = MockCreateProduct();
      mockUpdateProduct = MockUpdateProduct();
      mockDeleteProduct = MockDeleteProduct();
      mockSyncProducts = MockSyncProducts();
      productBloc = ProductBloc(
        getAllProducts: mockGetAllProducts,
        createProduct: mockCreateProduct,
        updateProduct: mockUpdateProduct,
        deleteProduct: mockDeleteProduct,
        syncProducts: mockSyncProducts,
      );
    });

    tearDown(() {
      productBloc.close();
    });

    test('initial state is ProductInitial', () {
      expect(productBloc.state, equals(ProductInitial()));
    });

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when LoadProducts is added',
      build: () {
        when(mockGetAllProducts()).thenAnswer(
          (_) async => [
            Product(
              id: 1,
              name: 'Test Product',
              description: 'Test Description',
              price: 99.99,
              imageUrl: 'https://example.com/image.jpg',
            )
          ],
        );
        return productBloc;
      },
      act: (bloc) => bloc.add(LoadProducts()),
      expect: () => [
        ProductLoading(),
        const ProductLoaded([
          Product(
            id: 1,
            name: 'Test Product',
            description: 'Test Description',
            price: 99.99,
            imageUrl: 'https://example.com/image.jpg',
          )
        ]),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadProducts fails',
      build: () {
        when(mockGetAllProducts()).thenThrow(Exception('Failed to load products'));
        return productBloc;
      },
      act: (bloc) => bloc.add(LoadProducts()),
      expect: () => [
        ProductLoading(),
        const ProductError('Exception: Failed to load products'),
      ],
    );
  });
}