// lib/screens/product_details_page.dart
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/review.dart'; // Ensure Review model is imported
import 'package:intellicart/presentation/screens/buyer/add_review_page.dart'; // <-- ADD THIS IMPORT
=======
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/models/review.dart';
import 'package:intellicart_frontend/bloc/cart/cart_bloc.dart';
import 'package:intellicart_frontend/bloc/wishlist/wishlist_bloc.dart';
import 'package:intellicart_frontend/data/models/cart_item.dart';
import 'package:intellicart_frontend/data/models/wishlist_item.dart';
import 'package:intellicart_frontend/data/datasources/api_service.dart';
import 'package:intellicart_frontend/presentation/bloc/buyer/review_bloc.dart';
import 'package:intellicart_frontend/utils/service_locator.dart';

import 'package:intellicart_frontend/presentation/screens/buyer/add_review_page.dart'; // <-- ADD THIS IMPORT
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

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
<<<<<<< HEAD
=======
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;

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
    
    // Load reviews when the page is initialized
    _loadProductReviews();
  }

  // Function to load product reviews
  Future<void> _loadProductReviews() async {
    try {
      // Use the shared ApiService instance from the service locator
      final apiService = serviceLocator.apiService;
      
      // First, make sure the token is loaded in the shared service
      final token = await serviceLocator.authRepository.getAuthToken();
      if (token != null && token.isNotEmpty) {
        apiService.setToken(token);
      }
      
      // Ensure the service is ready before making the request
      await apiService.ensureInitialized();
      
      final reviews = await apiService.getProductReviews(widget.product.id);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reviews: $e')),
        );
      }
    }
  }
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

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

<<<<<<< HEAD
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
=======
  
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

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
<<<<<<< HEAD
      // The body is wrapped in a Stack to allow for the sticky bottom bar
=======
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: lightTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: lightTextColor),
            onPressed: () {},
          ),
        ],
      ),
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
<<<<<<< HEAD
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

=======
            padding: const EdgeInsets.only(bottom: 160), // Add bottom padding to account for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
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
<<<<<<< HEAD
                                productImages[index],
                                fit: BoxFit.cover,
=======
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
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
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
<<<<<<< HEAD
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
=======
                                  color: Colors.white.withAlpha((255 * 0.5).round()),
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
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
<<<<<<< HEAD
                      _buildStarRating(4.5, starColor),
                      const SizedBox(width: 8.0),
                      const Text(
                        '4.5 (120 Reviews)',
                        style: TextStyle(
=======
                      _buildStarRating(_calculateAverageRating(), starColor),
                      const SizedBox(width: 8.0),
                      Text(
                        '${_calculateAverageRating().toStringAsFixed(1)} (${_reviews.length} Reviews)',
                        style: const TextStyle(
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
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
<<<<<<< HEAD
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
=======
                            onPressed: () async {
                              // Navigate to the AddReviewPage and await result
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddReviewPage(
                                    productId: widget.product.id,
                                  ),
                                ),
                              );
                              
                              // If a new review was submitted, refresh the reviews list
                              if (result != null) {
                                _loadProductReviews(); // Refresh the reviews
                              }
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
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
<<<<<<< HEAD
                      // Build reviews from the product model
                      if (widget.product.reviews.isEmpty)
=======
                      // Build reviews from fetched reviews
                      if (_isLoadingReviews)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_reviews.isEmpty)
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
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
<<<<<<< HEAD
                          itemCount: widget.product.reviews.length,
                          separatorBuilder: (context, index) =>
                          const SizedBox(height: 12.0),
                          itemBuilder: (context, index) {
                            final review = widget.product.reviews[index];
=======
                          itemCount: _reviews.length,
                          separatorBuilder: (context, index) =>
                          const SizedBox(height: 12.0),
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
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
<<<<<<< HEAD

                // Spacer to prevent content from being hidden by the bottom bar
                const SizedBox(height: 120),
=======
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
              ],
            ),
          ),

<<<<<<< HEAD
          // Sticky Bottom "Add to Cart" Bar
=======
          // Fixed Bottom "Add to Cart" Bar with Wishlist button
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
<<<<<<< HEAD
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0,
                  MediaQuery.of(context).padding.bottom + 12.0),
=======
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
              decoration: BoxDecoration(
                color: pageBgColor,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
<<<<<<< HEAD
                    color: Colors.black.withOpacity(0.05),
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
=======
                    color: Colors.black.withAlpha((255 * 0.1).round()),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Quantity controls row
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _decrementQuantity,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(6),
                          side: BorderSide(color: accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.remove, size: 16),
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF181411)),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _incrementQuantity,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(6),
                          side: BorderSide(color: accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.add, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Add product to persistent cart
                            final cartItem = CartItem(
                              productId: widget.product.id,
                              productName: widget.product.name,
                              productDescription: widget.product.description,
                              productPrice: widget.product.price,
                              productImageUrl: widget.product.imageUrl ?? '',
                              quantity: _quantity,
                            );
                            
                            context.read<CartBloc>().add(AddToCart(cartItem));
                            
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${widget.product.name} (Qty: $_quantity) to cart!'),
                                backgroundColor: accentColor,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Wishlist button below
                  OutlinedButton.icon(
                    onPressed: () {
                      // Add product to wishlist
                      final wishlistItem = WishlistItem(
                        productId: widget.product.id,
                        productName: widget.product.name,
                        productDescription: widget.product.description,
                        productPrice: widget.product.price,
                        productImageUrl: widget.product.imageUrl ?? '',
                      );
                      
                      context.read<WishlistBloc>().add(AddToWishlist(wishlistItem));
                      
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${widget.product.name} to wishlist!'),
                          backgroundColor: accentColor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite_border, color: Color(0xFFD97706), size: 16),
                    label: const Text(
                      'Add to Wishlist',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD97706)),
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
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
<<<<<<< HEAD
=======
  
  // Helper function to calculate average rating
  double _calculateAverageRating() {
    if (_reviews.isEmpty) {
      return 0.0; // Return 0 if no reviews
    }
    
    double totalRating = 0.0;
    for (final review in _reviews) {
      totalRating += review.rating.toDouble();
    }
    return totalRating / _reviews.length;
  }
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
}