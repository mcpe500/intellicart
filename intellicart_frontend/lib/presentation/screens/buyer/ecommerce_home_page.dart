// lib/screens/ecommerce_home_page.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/data/repositories/app_repository_impl.dart';
import 'package:intellicart_frontend/bloc/cart/cart_bloc.dart';
import 'package:intellicart_frontend/bloc/wishlist/wishlist_bloc.dart';
import 'package:intellicart_frontend/data/models/cart_item.dart';
import 'package:intellicart_frontend/data/models/wishlist_item.dart';
import 'package:intellicart_frontend/presentation/screens/buyer/ecommerce_search_page.dart';
import 'package:intellicart_frontend/presentation/screens/buyer/product_details_page.dart';
import 'package:intellicart_frontend/presentation/screens/core/profile_page.dart'; // Import the new ProfilePage
import 'package:intellicart_frontend/presentation/screens/buyer/cart_page.dart'; // Import the new CartPage
import 'package:intellicart_frontend/presentation/screens/buyer/wishlist_page.dart'; // Import the new WishlistPage

class EcommerceHomePage extends StatefulWidget {
  const EcommerceHomePage({super.key});

  @override
  State<EcommerceHomePage> createState() => _EcommerceHomePageState();
}

class _EcommerceHomePageState extends State<EcommerceHomePage> {
  int _currentIndex = 0; // State to track the selected tab index
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final repository = AppRepositoryImpl();
      List<Product> products = await repository.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _products = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomePageContent(products: _products),
      const EcommerceSearchPage(),
      const CartPage(),
      const WishlistPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intellicart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EcommerceSearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Widget to display the Home Page Content
  Widget _buildHomePageContent(BuildContext context) {
    return _HomePageContent(products: _products);
  }
}

// Separate widget to encapsulate the home page content
class _HomePageContent extends StatelessWidget {
  final List<Product> products;

  const _HomePageContent({required this.products});

  @override
  Widget build(BuildContext context) {
    final warmOrange700 = const Color(0xFFC4451F); // Warm orange color
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Categories',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: warmOrange700,
                  ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryItem(context, 'Electronics', Icons.phone_iphone),
                _buildCategoryItem(context, 'Fashion', Icons.shopping_bag),
                _buildCategoryItem(context, 'Home', Icons.home),
                _buildCategoryItem(context, 'Beauty', Icons.brush),
                _buildCategoryItem(context, 'Sports', Icons.sports_soccer),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Products Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Products',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: warmOrange700,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all products page
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          _buildProductGrid(context, products: products, warmOrange700: warmOrange700),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon) {
    final warmOrange700 = const Color(0xFFC4451F);
    return Container(
      width: 80,
      margin: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: warmOrange700.withOpacity(0.1),
            child: Icon(icon, color: warmOrange700),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, {required List<Product> products, required Color warmOrange700}) {
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No products available'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(
          product: product,
          warmOrange700: warmOrange700,
        );
      },
    );
  }
}

// Widget to display each individual product card
class _ProductCard extends StatelessWidget {
  final Product product;
  final Color warmOrange700;

  const _ProductCard({
    required this.product,
    required this.warmOrange700,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.imageUrl.isNotEmpty ? product.imageUrl : 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/placeholder.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: warmOrange700,
                        ),
                      ),
                      if (product.originalPrice != null && product.originalPrice!.isNotEmpty)
                        Text(
                          '\$${product.originalPrice}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}