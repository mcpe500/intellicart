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
      // Try to load products from the repository
      final repository = AppRepositoryImpl();
      List<Product> products = await repository.getProducts();
      
      // If no products in repository, keep the empty list
      // No mock data should be used, as per requirements
      
      setState(() {
        _products = products;
      });
    } catch (e) {
      print('Error loading products: $e');
      // On error, keep the empty list
      setState(() {
        _products = [];
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the pages list inside build so it updates when _products changes
    final List<Widget> pages = [
      // Index 0: Home Content
      _HomePageContent(products: _products),
      // Index 1: Categories (using the search page for now)
      const EcommerceSearchPage(),
      // Index 2: Cart
      const CartPage(),
      // Index 3: Wishlist
      const WishlistPage(),
      // Index 4: Profile
      const ProfilePage(),
    ];

    const Color warmOrange500 = Color(0xFFFF9800);
    const Color warmGray500 = Color(0xFF9E9E9E);

    return Scaffold(
      body: pages[_currentIndex], // Display the page corresponding to the current index
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

// ---- HELPER WIDGET FOR HOME PAGE CONTENT ----
// We extract the original body of the home page into its own widget
// to keep the code clean.
class _HomePageContent extends StatelessWidget {
  const _HomePageContent({
    required this.products,
  });

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    const Color warmOrange100 = Color(0xFFFFF4E6);
    const Color warmOrange500 = Color(0xFFFF9800);
    const Color warmOrange700 = Color(0xFFF57C00);
    const Color warmGray100 = Color(0xFFF5F5F5);
    const Color warmGray500 = Color(0xFF9E9E9E);
    const Color warmGray800 = Color(0xFF424242);

    return SafeArea(
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
                  _buildProductGrid(
                    context,
                    products: products.length >= 2 ? products.sublist(0, 2) : products,
                    warmOrange700: warmOrange700,
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
                  _buildProductGrid(
                    context,
                    products: products.length > 2 ? products.sublist(2) : [],
                    warmOrange700: warmOrange700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, {required List<Product> products, required Color warmOrange700}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255 * 0.1).round()),
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
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsPage(product: product),
                  ),
                );
              },
              child: Image.network(
                product.imageUrl ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
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
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Add product to persistent cart
                          final cartItem = CartItem(
                            productId: product.id,
                            productName: product.name,
                            productDescription: product.description,
                            productPrice: product.price,
                            productImageUrl: product.imageUrl ?? '',
                            quantity: 1, // Default quantity
                          );
                          
                          context.read<CartBloc>().add(AddToCart(cartItem));
                          
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${product.name} to cart!'),
                              backgroundColor: warmOrange700,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: warmOrange700,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add product to wishlist
                          final wishlistItem = WishlistItem(
                            productId: product.id,
                            productName: product.name,
                            productDescription: product.description,
                            productPrice: product.price,
                            productImageUrl: product.imageUrl ?? '',
                          );
                          
                          context.read<WishlistBloc>().add(AddToWishlist(wishlistItem));
                          
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${product.name} to wishlist!'),
                              backgroundColor: warmOrange700,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: warmOrange700,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(color: warmOrange700),
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}