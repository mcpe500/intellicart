import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intellicart/data/repositories/app_repository_impl.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/review.dart';
import 'package:intellicart/presentation/bloc/buyer/product_bloc.dart';
import 'package:intellicart/presentation/screens/buyer/liked_products_page.dart';

class _FakeRepo extends AppRepositoryImpl {
  final List<Product> _products;
  _FakeRepo(this._products);

  @override
  Future<List<Product>> getProducts() async => _products;

  @override
  Future<bool> syncFromBackend() async => false;

  @override
  Future<Product> addReviewToProduct(String productId, Review review) async {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('LikedProductsPage shows empty state when no likes', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final repo = _FakeRepo([
      Product(
        id: '1',
        name: 'Classic Leather Tote',
        description: 'Bag',
        price: '\$120.00',
        imageUrl: 'https://via.placeholder.com/300',
        reviews: [],
      ),
    ]);

    final bloc = ProductBloc(repository: repo)..add(LoadProducts());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: bloc,
          child: const LikedProductsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Liked Products'), findsOneWidget);
    expect(find.text('No liked products yet!'), findsOneWidget);
  });

  testWidgets('LikedProductsPage lists liked items', (tester) async {
    SharedPreferences.setMockInitialValues({
      'liked_product_ids': ['2']
    });

    final repo = _FakeRepo([
      Product(
        id: '1',
        name: 'Classic Leather Tote',
        description: 'Bag',
        price: '\$120.00',
        imageUrl: 'https://via.placeholder.com/300',
        reviews: [],
      ),
      Product(
        id: '2',
        name: 'Aura Wireless Buds',
        description: 'Audio',
        price: '\$89.99',
        imageUrl: 'https://via.placeholder.com/300',
        reviews: [],
      ),
    ]);

    final bloc = ProductBloc(repository: repo)..add(LoadProducts());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: bloc,
          child: const LikedProductsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Aura Wireless Buds'), findsOneWidget);
    expect(find.text('Classic Leather Tote'), findsNothing);
  });
}
