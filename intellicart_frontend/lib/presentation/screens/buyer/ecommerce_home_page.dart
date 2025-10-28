// lib/screens/ecommerce_home_page.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/presentation/bloc/buyer/product_bloc.dart';
import 'package:intellicart/presentation/screens/buyer/ecommerce_search_page.dart';
import 'package:intellicart/presentation/screens/buyer/product_details_page.dart';
import 'package:intellicart/presentation/screens/core/profile_page.dart'; // Import the new ProfilePage
import 'package:intellicart/presentation/screens/buyer/cart_page.dart'; // Import the new CartPage
import 'package:intellicart/presentation/screens/buyer/wishlist_page.dart'; // Import the new WishlistPage
import 'package:intellicart/features/product/presentation/widgets/product_grid.dart';

class EcommerceHomePage extends StatefulWidget {
  const EcommerceHomePage({super.key});

  @override
  State<EcommerceHomePage> createState() => _EcommerceHomePageState();
}

class _EcommerceHomePageState extends State<EcommerceHomePage> {
  int _currentIndex = 0; // State to track the selected tab index

  // List of the pages to be displayed for each tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Index 0: Home Content - Will be wrapped in BlocProvider
      const _HomePageContent(),
      // Index 1: Categories (using the search page for now)
      const EcommerceSearchPage(),
      // Index 2: Cart
      const CartPage(),
      // Index 3: Wishlist
      const WishlistPage(),
      // Index 4: Profile
      const ProfilePage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color warmOrange500 = Color(0xFFFF9800);
    const Color warmGray500 = Color(0xFF9E9E9E);

    return Scaffold(
      body: _pages[_currentIndex], // Display the page corresponding to the current index
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped, // Call this method when a tab is tapped
          selectedItemColor: warmOrange500,
          unselectedItemColor: warmGray500,
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 12.0),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
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
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}

// ---- HOME PAGE CONTENT WITH BLoC ----
class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is ProductError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(LoadProducts());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProductLoaded) {
          return _buildHomePageContent(context, state.products);
        } else {
          // Initial state, load products
          context.read<ProductBloc>().add(LoadProducts());
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildHomePageContent(BuildContext context, List<Product> products) {
    const Color warmOrange100 = Color(0xFFFFF4E6);
    const Color warmOrange500 = Color(0xFFFF9800);
    const Color warmOrange700 = Color(0xFFF57C00);
    const Color warmGray100 = Color(0xFFF5F5F5);
    const Color warmGray500 = Color(0xFF9E9E9E);
    const Color warmGray800 = Color(0xFF424242);

    return Scaffold(
      backgroundColor: warmGray100,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: warmOrange100,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EcommerceSearchPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 12),
                            Icon(Icons.search, color: warmGray500),
                            SizedBox(width: 8),
                            Text('Search for products...', style: TextStyle(fontSize: 14.0, color: warmGray500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: warmGray800),
                    onPressed: () {
                      // Navigate to cart page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: warmGray800),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Based on Your Recent Searches',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: warmGray800),
                    ),
                    const SizedBox(height: 12.0),
                    ProductGrid(
                      products: products.length >= 2 ? products.sublist(0, 2) : products,
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Popular Right Now',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: warmGray800),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'See All',
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: warmOrange500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    if (products.length > 2) 
                      ProductGrid(
                        products: products.sublist(2),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// The Product Card now navigates to the details page
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.warmOrange700,
  });

  final Product product;
  final Color warmOrange700;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        // ... (The rest of the _ProductCard code is unchanged)
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product.price,
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: warmOrange700),
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