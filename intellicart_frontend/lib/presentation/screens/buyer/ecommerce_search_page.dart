// lib/screens/ecommerce_search_page.dart
import 'package:flutter/material.dart';

class EcommerceSearchPage extends StatelessWidget {
  const EcommerceSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the custom colors used in the HTML for consistency
    const Color primaryTextColor = Color(0xFF181411);
    const Color accentRed = Color(0xFFE57373);
    const Color lightGreyBackground = Color(0xFFF5F2F0);
    const Color greyIconColor = Color(0xFF8A7260);
<<<<<<< HEAD
    const Color orangeAccent = Color(0xFFE65100);
=======
    
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: primaryTextColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for products...',
                hintStyle: TextStyle(color: greyIconColor),
                prefixIcon: Icon(Icons.search, color: greyIconColor),
                filled: true,
                fillColor: lightGreyBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Recent Searches Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: accentRed,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recent Searches Tags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 8.0,
              children: [
                _buildSearchTag('Running Shoes', lightGreyBackground, primaryTextColor),
                _buildSearchTag('Wireless Earbuds', lightGreyBackground, primaryTextColor),
                _buildSearchTag('Coffee Maker', lightGreyBackground, primaryTextColor),
              ],
            ),
          ),

          // Browse by Category Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: Text(
              'Browse by Category',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
          ),

          // Categories Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // To prevent scrolling inside the column
                children: [
                  _buildCategoryItem(Icons.phone_iphone, 'Electronics', const Color(0xFFFFE0B2), const Color(0xFFE65100)),
                  _buildCategoryItem(Icons.style, 'Fashion', const Color(0xFFC8E6C9), const Color(0xFF2E7D32)),
                  _buildCategoryItem(Icons.chair, 'Home & Kitchen', const Color(0xFFFFCDD2), const Color(0xFFB71C1C)),
                  _buildCategoryItem(Icons.brush, 'Beauty', const Color(0xFFD1C4E9), const Color(0xFF4527A0)),
                  _buildCategoryItem(Icons.auto_stories, 'Books & Media', const Color(0xFFB2EBF2), const Color(0xFF006064)),
                  _buildCategoryItem(Icons.sports_basketball, 'Sports', const Color(0xFFF0F4C3), const Color(0xFF558B2F)),
                  _buildCategoryItem(Icons.smart_toy, 'Toys & Games', const Color(0xFFFFECB3), const Color(0xFFFF6F00)),
                  _buildCategoryItem(Icons.category, 'More', const Color(0xFFD7CCC8), const Color(0xFF3E2723)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500, // Medium weight for font-medium
              color: textColor,
            ),
          ),
          const SizedBox(width: 8.0),
          Icon(
            Icons.close,
            size: 18.0,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30.0, color: iconColor),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500, // Medium weight for font-medium
            color: Color(0xFF181411), // primaryTextColor
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
