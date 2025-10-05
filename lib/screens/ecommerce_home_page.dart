// lib/screens/ecommerce_home_page.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/screens/ecommerce_search_page.dart'; // Import the new search page

class EcommerceHomePage extends StatelessWidget {
  final List<Product> products;

  const EcommerceHomePage({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    // Define the custom colors used in the HTML for consistency
    const Color warmOrange100 = Color(0xFFFFF4E6);
    const Color warmOrange500 = Color(0xFFFF9800);
    const Color warmOrange700 = Color(0xFFF57C00);
    const Color warmGray100 = Color(0xFFF5F5F5);
    const Color warmGray500 = Color(0xFF9E9E9E);
    const Color warmGray800 = Color(0xFF424242);

    return Scaffold(
      backgroundColor: warmGray100, // Equivalent to bg-[var(--warm-gray-100)]
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: warmOrange100, // Equivalent to bg-[var(--warm-orange-100)]
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector( // Wrap the search bar in a GestureDetector
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EcommerceSearchPage()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const TextField(
                          enabled: false, // Disable actual text input on this page
                          decoration: InputDecoration(
                            hintText: 'Search for products...',
                            hintStyle: TextStyle(fontSize: 14.0, color: warmGray500),
                            prefixIcon: Icon(Icons.search, color: warmGray500),
                            border: InputBorder.none,
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: warmGray800),
                    onPressed: () {},
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
                    // Based on Your Recent Searches Section
                    Text(
                      'Based on Your Recent Searches',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: warmGray800),
                    ),
                    const SizedBox(height: 12.0),
                    _buildProductGrid(
                      context,
                      products: products.sublist(0, 2),
                      warmOrange700: warmOrange700,
                    ),
                    const SizedBox(height: 24.0),

                    // Popular Right Now Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Popular Right Now',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: warmGray800),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'See All',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: warmOrange500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    _buildProductGrid(
                      context,
                      products: products.sublist(2),
                      warmOrange700: warmOrange700,
                    ),
                  ],
                ),
              ),
            ),
            // Footer Navigation
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: BottomNavigationBar(
                currentIndex: 0,
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
                    icon: Icon(Icons.favorite),
                    label: 'Wishlist',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Account',
                  ),
                ],
                onTap: (index) {
                  // No functionality required, so we just have an empty onTap
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context,
      {required List<Product> products, required Color warmOrange700}) {
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    Key? key,
    required this.product,
    required this.warmOrange700,
  }) : super(key: key);

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
            color: Colors.grey.withOpacity(0.1),
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
                  style: const TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.w600),
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
    );
  }
}