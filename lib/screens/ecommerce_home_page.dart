import 'package:flutter/material.dart';

class EcommerceHomePage extends StatelessWidget {
  const EcommerceHomePage({super.key});

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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const TextField(
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
                      products: [
                        _Product(
                          name: 'Stylish Headphones',
                          description: 'For immersive audio',
                          price: '\$49.99',
                          imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDMDDt1s-XFmFZSH0ueZa_h2OY0-wSr0PwaY4s6z7CWYwY15RQ84AFwOUPae2BDOXI73lUD5rch6jWyiRaX4V84CzDJNkS3ZrCKWSrXRRGo1kJXmnoyVW2LqNBZ62Uf7k5j3ekVHTTDd6a5cxMqwDbZ1UGyXbMrEAX8U-B1hVJpAuVefrbzAd3ewrAojReuO9pG2MmbKxoYD4oiedLQvR5H7RKR-8vKdVE0NJSNpysXDQ4BgY0CwHSmFB99DMdnU6fIGsftaer72icT',
                        ),
                        _Product(
                          name: 'Wireless Earbuds',
                          description: 'Compact and convenient',
                          price: '\$79.99',
                          imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAU7U_kS6_gA60CXLu3bQedKs7gieDR-Od4nf01tYU1wiMTn7rnT9gQjZJrXCWSbd3qSnnAb4ohNgEe6Rqkme_SFVx3pdpdg7dDl2RXverxSCbNfl06zi79wznmywgEy2tjT0vzBqLgdBrNAeOzxMZTVrYva74Y2ClHL8Nm9HUM4xqsf_MkIdsQAJntvJyEyYwBki7Vsq1huMtI8DDohIKbLItAlgtMAfQNC14jLnulQjuc74GOglQOVmneWnEV6ieRiEQrTXOZM_Sr',
                        ),
                      ],
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
                      products: [
                        _Product(
                          name: 'Smartwatch Series 7',
                          description: 'Track your fitness',
                          price: '\$199.99',
                          imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBlvRiH9bIWU65_lBYwcvJO1PygVoEkI9g5iQGwZ-UeO0crUGl_2wmFVd1ToWuy4tEoM9sxIwOLVk7TVgfA-wDl6t3Fo0QbEU71iYp-3wlAofhrlSh8Oc4jDxrXqfs73jxvkOy0li3v2FWOoieKf3H4nxdqdXu4ofYUV3YUbyb4kwg_uwnJTrLDSDDsP4u8tBvye717EZWj5mO7cVjP4_TCSuuPLqIXFO7t6SivfMVOZtxFykm2_wP54OteOyjVQuFFVyamWCzPsTiC',
                        ),
                        _Product(
                          name: 'Portable Speaker',
                          description: 'Music on the go',
                          price: '\$35.00',
                          imageUrl:
                          'data:image/jpeg;base64,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',
                        ),
                        _Product(
                          name: 'Ergonomic Mouse',
                          description: 'For comfortable work',
                          price: '\$29.99',
                          imageUrl:
                          'https://pressplayid.com/cdn/shop/files/IRIS_Cover_Web_1.jpg?v=1732000094',
                        ),
                        _Product(
                          name: 'Gaming Keyboard',
                          description: 'Mechanical keys',
                          price: '\$89.99',
                          imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCKcVS8MIbEXwfBC1Gzd_B2heHbg4uXjiQQU1pbDe01e106lNdREMhXAWdRUMZm3Pl_qNp4rc3JxDkSC4uDHodhAa7qYSOVuiPHVIveYFOIP2gqVwmCb3m6okdgoCrs8Ljsuxivk_aQnM4B-vCdI3uONUUc8-l-RyzHUOoLKLcrzOFsgxF0k2mJzrDIlOjl86koe3k6j2CfMG-Cb7muUsWoNNu8O2jV3TLP36wywCgwwxxM_g4iuymgaxWyD2xBWX11hz-bat74JWfm',
                        ),
                      ],
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

  // Helper method to build the product grid
  Widget _buildProductGrid(BuildContext context,
      {required List<_Product> products, required Color warmOrange700}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75, // Adjust as needed to fit content
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

// A simple data class for product information
class _Product {
  final String name;
  final String description;
  final String price;
  final String imageUrl;

  _Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

// Widget for a single product card
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    Key? key,
    required this.product,
    required this.warmOrange700,
  }) : super(key: key);

  final _Product product;
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
              // You can add a loading builder or error builder if needed
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