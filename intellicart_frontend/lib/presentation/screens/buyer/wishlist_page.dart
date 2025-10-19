import 'package:flutter/material.dart';
// FIX: Changed to a direct package import for better path resolution.
import 'package:intellicart_frontend/models/product.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // Dummy data for wishlist items
  // FIX: Updated the Product objects to match the constructor in the Product model.
  // - Removed 'id' and 'category' as they are not defined in the Product class.
  // - Changed the 'price' to a String to match the model's data type.
  final List<Product> wishlist = [
    Product(
      id: '1',
      name: 'Classic Leather Jacket',
      description: 'A timeless leather jacket for all seasons.',
      price: '\$129.99',
      imageUrl: 'https://placehold.co/400x400/000000/FFFFFF?text=Jacket',
      reviews: [],
    ),
    Product(
      id: '2',
      name: 'Wireless Bluetooth Headphones',
      description: 'High-fidelity sound with noise cancellation.',
      price: '\$89.99',
      imageUrl: 'https://placehold.co/400x400/5E5E5E/FFFFFF?text=Headphones',
      reviews: [],
    ),
     Product(
        id: '3',
        name: 'Stylish Headphones',
        description: 'For immersive audio',
        price: '\$49.99',
        originalPrice: '\$60.00',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDMDDt1s-XFmFZSH0ueZa_h2OY0-wSr0PwaY4s6z7CWYwY15RQ84AFwOUPae2BDOXI73lUD5rch6jWyiRaX4V84CzDJNkS3ZrCKWSrXRRGo1kJXmnoyVW2LqNBZ62Uf7k5j3ekVHTTDd6a5cxMqwDbZ1UGyXbMrEAX8U-B1hVJpAuVefrbzAd3ewrAojReuO9pG2MmbKxoYD4oiedLQvR5H7RKR-8vKdVE0NJSNpysXDQ4BgY0CwHSmFB99DMdnU6fIGsftaer72icT',
        reviews: [],
      ),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF181411);
    const Color accentColor = Color(0xFFD97706);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: wishlist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Your wishlist is empty.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          product.imageUrl ?? 'https://via.placeholder.com/60',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 60),
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        product.price,
                        style: const TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined,
                                color: primaryTextColor),
                            tooltip: 'Add to Cart',
                            onPressed: () {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to cart!'),
                                  backgroundColor: accentColor,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            tooltip: 'Remove from Wishlist',
                            onPressed: () {
                              setState(() {
                                wishlist.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

