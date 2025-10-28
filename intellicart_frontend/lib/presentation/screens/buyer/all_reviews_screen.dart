import 'package:flutter/material.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/review.dart';

class AllReviewsScreen extends StatefulWidget {
  final Product product;

  const AllReviewsScreen({super.key, required this.product});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  late List<Review> _allReviews;
  late List<Review> _filteredReviews;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allReviews = widget.product.reviews;
    _filteredReviews = _allReviews;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterReviews(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredReviews = _allReviews;
      });
    } else {
      setState(() {
        _filteredReviews = _allReviews.where((review) {
          return review.title.toLowerCase().contains(query.toLowerCase()) ||
              review.reviewText.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  Widget _buildStarRating(double rating, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating ? Icons.star_half : Icons.star_border),
          color: color,
          size: 16.0,
        );
      }),
    );
  }

  Widget _buildReviewCard(Review review, Color starColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStarRating(review.rating.toDouble(), starColor),
              Text(
                review.timeAgo,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            review.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4.0),
          Text(
            review.reviewText,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          // Display images if they exist
          if (review.images != null && review.images!.isNotEmpty)
            const SizedBox(height: 8.0),
          if (review.images != null && review.images!.isNotEmpty)
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: review.images!.map((image) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 20, color: Colors.grey),
                      ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF181411);
    const Color lightTextColor = Color(0xFF8A7260);
    const Color starColor = Color(0xFFFF9500);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reviews'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryTextColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search reviews...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onChanged: _filterReviews,
              ),
            ),
            
            // Reviews title and count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                Text(
                  '${_filteredReviews.length} reviews',
                  style: const TextStyle(
                    fontSize: 14,
                    color: lightTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Reviews list
            Expanded(
              child: _filteredReviews.isEmpty
                  ? const Center(
                      child: Text('No reviews match your search.'),
                    )
                  : ListView.builder(
                      itemCount: _filteredReviews.length,
                      itemBuilder: (context, index) {
                        return _buildReviewCard(_filteredReviews[index], starColor);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}