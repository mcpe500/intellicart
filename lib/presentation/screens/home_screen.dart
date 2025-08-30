import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/presentation/bloc/product_bloc.dart';
import 'package:intellicart/presentation/bloc/product_event.dart';
import 'package:intellicart/presentation/bloc/product_state.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/data/datasources/api_service.dart';
import 'package:intellicart/data/datasources/database_service.dart';
import 'package:intellicart/data/repositories/product_repository_impl.dart';
import 'package:intellicart/domain/usecases/get_all_products.dart';
import 'package:intellicart/domain/usecases/create_product.dart';
import 'package:intellicart/domain/usecases/sync_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final databaseService = DatabaseService.instance;
    final productRepository = ProductRepositoryImpl(
      apiService: apiService,
      databaseService: databaseService,
    );
    final getAllProducts = GetAllProducts(productRepository);
    final createProduct = CreateProduct(productRepository);
    final syncProducts = SyncProducts(productRepository);

    return BlocProvider(
      create: (context) => ProductBloc(
        getAllProducts: getAllProducts,
        createProductUseCase: createProduct,
        syncProductsUseCase: syncProducts,
      )..add(LoadProducts()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Intellicart'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () {
                // For sync, we need to get current products first
                // In a real app, you might want a separate event for this
                context.read<ProductBloc>().add(LoadProducts());
              },
            ),
          ],
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductInitial) {
              return const Center(child: Text('Initializing...'));
            } else if (state is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductLoaded) {
              return ProductListView(products: state.products);
            } else if (state is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductBloc>().add(LoadProducts());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Unknown state'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // For simplicity, we're adding a hardcoded product
            // In a real app, you would show a form dialog
            final newProduct = Product(
              id: 0, // Will be set by database
              name: 'New Product',
              description: 'Created at ${DateTime.now()}',
              price: 99.99,
              imageUrl: 'https://via.placeholder.com/150',
            );
            context.read<ProductBloc>().add(CreateProductEvent(newProduct));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class ProductListView extends StatelessWidget {
  final List<Product> products;

  const ProductListView({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProductBloc>().add(LoadProducts());
      },
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(product.name),
              subtitle: Text(product.description),
              trailing: Text('\$${product.price.toStringAsFixed(2)}'),
            ),
          );
        },
      ),
    );
  }
}