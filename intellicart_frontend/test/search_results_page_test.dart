import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/data/repositories/app_repository_impl.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/review.dart';
import 'package:intellicart/presentation/bloc/buyer/product_bloc.dart';
import 'package:intellicart/presentation/screens/buyer/search_results_page.dart';

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
  testWidgets('SearchResultsPage shows header and filtered items', (tester) async {
    final repo = _FakeRepo([
      Product(
        id: '1',
        name: 'Smartwatch X-Pro',
        description: 'Great watch',
          price: '\$199.99',
        imageUrl: 'https://via.placeholder.com/300',
        reviews: [Review(title: 't', reviewText: 'r', rating: 5, timeAgo: '1d')],
      ),
      Product(
        id: '2',
        name: 'Leather Backpack',
        description: 'Bag',
          price: '\$120.00',
        imageUrl: 'https://via.placeholder.com/300',
        reviews: [],
      )
    ]);

    final bloc = ProductBloc(repository: repo)..add(LoadProducts());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: bloc,
          child: const SearchResultsPage(initialQuery: 'Smartwatch'),
        ),
      ),
    );

    // Let bloc load
    await tester.pumpAndSettle();

    expect(find.text('Search Results'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.textContaining('Smartwatch'), findsWidgets);
    // Should show the smartwatch card
    expect(find.text('Smartwatch X-Pro'), findsOneWidget);
    // Should not show backpack when filtering by Smartwatch
    expect(find.text('Leather Backpack'), findsNothing);
  });
}
