// lib/screens/product_details_page.dart
import 'package:flutter/material.dart';
import 'package:intellicart_frontend/models/product.dart';

import 'package:intellicart_frontend/presentation/screens/buyer/add_review_page.dart'; // <-- ADD THIS IMPORT

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _quantity = 1; // State variable for the quantity

  // Function to increment quantity
  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  // Function to decrement quantity, with a check to not go below 1
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page;
      if (page != null) {
        setState(() {
          _currentPage = page.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define colors from the HTML for consistency
    const Color pageBgColor = Color(0xFFFDFBF8);
    const Color primaryTextColor = Color(0xFF181411);
    const Color secondaryTextColor = Color(0xFF655546);
    const Color lightTextColor = Color(0xFF8A7260);
    const Color accentColor = Color(0xFFD95F18);
    const Color starColor = Color(0xFFFF9500);

    // Dummy data for the carousel, as the model doesn't contain multiple images yet
    final List<String> productImages = [
      widget.product.imageUrl,
      // You can add more image URLs here if your product model supports it in the future
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1999&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=2070&auto=format&fit=crop',
    ];

    return Scaffold(
      backgroundColor: pageBgColor,
      // The body is wrapped in a Stack to allow for the sticky bottom bar
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom App Bar section (using a Padding and Row instead of a real AppBar)
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 4.0,
                      right: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: lightTextColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Product Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: lightTextColor),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Image Carousel
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 13,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: productImages.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                productImages[index] ?? 'https://via.placeholder.com/300',
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(Icons.broken_image)),
                              ),
                            );
                          },
                        ),
                        // Dots Indicator
                        Positioned(
                          bottom: 16.0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                            List.generate(productImages.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0),
                                width: _currentPage == index ? 10.0 : 8.0,
                                height: _currentPage == index ? 10.0 : 8.0,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((255 * 0.5).round()),
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Product Title
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                  child: Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      height: 1.2,
                    ),
                  ),
                ),

                // Star Rating
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      _buildStarRating(4.5, starColor),
                      const SizedBox(width: 8.0),
                      const Text(
                        '4.5 (120 Reviews)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.product.price,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      if (widget.product.originalPrice != null)
                        Text(
                          widget.product.originalPrice!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: lightTextColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Customer Reviews Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Customer Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to the AddReviewPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddReviewPage(
                                    // We'll use the product name as a stand-in for ID
                                    productId: widget.product.name,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Write a Review', // <-- CHANGED TEXT
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // Build reviews from the product model
                      if (widget.product.reviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            'No reviews yet for this product.',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.product.reviews.length,
                          separatorBuilder: (context, index) =>
                          const SizedBox(height: 12.0),
                          itemBuilder: (context, index) {
                            final review = widget.product.reviews[index];
                            return _buildReviewCard(
                              review.title,
                              review.reviewText,
                              review.rating,
                              review.timeAgo,
                              starColor,
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // Spacer to prevent content from being hidden by the bottom bar
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Sticky Bottom "Add to Cart" Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0,
                  MediaQuery.of(context).padding.bottom + 12.0),
              decoration: BoxDecoration(
                color: pageBgColor,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.05).round()),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: accentColor),
                          onPressed: _decrementQuantity,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: accentColor),
                          onPressed: _incrementQuantity,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        print(
                            'Added ${widget.product.name} (Qty: $_quantity) to cart.');
                        // Here you would typically call a state management provider
                        // or bloc to actually add the item to the cart.
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the star rating row
  Widget _buildStarRating(double rating, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating ? Icons.star_half : Icons.star_border),
          color: color,
          size: 20.0,
        );
      }),
    );
  }

  // Helper widget for a single review card
  Widget _buildReviewCard(
      String title, String review, int rating, String time, Color starColor) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStarRating(rating.toDouble(), starColor),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4.0),
          Text(
            review,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
