// lib/data/datasources/mock_backend.dart
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/review.dart';

class MockBackend {
  // Simulates fetching all products from a remote server.
  Future<List<Product>> fetchProducts() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    // This is the same data that was previously in main.dart
    return [
      Product(
        name: 'Stylish Headphones',
        description: 'For immersive audio',
        price: '\$49.99',
        originalPrice: '\$60.00',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDMDDt1s-XFmFZSH0ueZa_h2OY0-wSr0PwaY4s6z7CWYwY15RQ84AFwOUPae2BDOXI73lUD5rch6jWyiRaX4V84CzDJNkS3ZrCKWSrXRRGo1kJXmnoyVW2LqNBZ62Uf7k5j3ekVHTTDd6a5cxMqwDbZ1UGyXbMrEAX8U-B1hVJpAuVefrbzAd3ewrAojReuO9pG2MmbKxoYD4oiedLQvR5H7RKR-8vKdVE0NJSNpysXDQ4BgY0CwHSmFB99DMdnU6fIGsftaer72icT',
        reviews: [
          const Review(
            title: 'Absolutely beautiful!',
            reviewText:
                "The quality is amazing, and the sound is so immersive. It's the perfect size and looks even better in person.",
            rating: 5,
            timeAgo: '2 days ago',
          ),
          const Review(
            title: 'Great headphones, but a bit tight.',
            reviewText:
                "I love the design and the material. It's a bit tight at first, but I'm sure it will loosen up with use. Very happy with my purchase.",
            rating: 4,
            timeAgo: '1 week ago',
          ),
        ],
      ),
      Product(
        name: 'Wireless Earbuds',
        description: 'Compact and convenient',
        price: '\$79.99',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAU7U_kS6_gA60CXLu3bQedKs7gieDR-Od4nf01tYU1wiMTn7rnT9gQjZJrXCWSbd3qSnnAb4ohNgEe6Rqkme_SFVx3pdpdg7dDl2RXverxSCbNfl06zi79wznmywgEy2tjT0vzBqLgdBrNAeOzxMZTVrYva74Y2ClHL8Nm9HUM4xqsf_MkIdsQAJntvJyEyYwBki7Vsq1huMtI8DDohIKbLItAlgtMAfQNC14jLnulQjuc74GOglQOVmneWnEV6ieRiEQrTXOZM_Sr',
        reviews: [
          const Review(
            title: 'Fantastic sound!',
            reviewText:
                "These earbuds have incredible sound quality for their size. The battery life is also impressive.",
            rating: 5,
            timeAgo: '5 days ago',
          ),
        ],
      ),
      Product(
        name: 'Smartwatch Series 7',
        description: 'Track your fitness',
        price: '\$199.99',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBlvRiH9bIWU65_lBYwcvJO1PygVoEkI9g5iQGwZ-UeO0crUGl_2wmFVd1ToWuy4tEoM9sxIwOLVk7TVgfA-wDl6t3Fo0QbEU71iYp-3wlAofhrlSh8Oc4jDxrXqfs73jxvkOy0li3v2FWOoieKf3H4nxdqdXu4ofYUV3YUbyb4kwg_uwnJTrLDSDDsP4u8tBvye717EZWj5mO7cVjP4_TCSuuPLqIXFO7t6SivfMVOZtxFykm2_wP54OteOyjVQuFFVyamWCzPsTiC',
        reviews: [],
      ),
      Product(
        name: 'Portable Speaker',
        description: 'Music on the go',
        price: '\$35.00',
        imageUrl:
            'data:image/jpeg;base64,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',
        reviews: [],
      ),
      Product(
        name: 'Ergonomic Mouse',
        description: 'For comfortable work',
        price: '\$29.99',
        imageUrl:
            'https://pressplayid.com/cdn/shop/files/IRIS_Cover_Web_1.jpg?v=1732000094',
        reviews: [],
      ),
      Product(
        name: 'Gaming Keyboard',
        description: 'Mechanical keys',
        price: '\$89.99',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCKcVS8MIbEXwfBC1Gzd_B2heHbg4uXjiQQU1pbDe01e106lNdREMhXAWdRUMZm3Pl_qNp4rc3JxDkSC4uDHodhAa7qYSOVuiPHVIveYFOIP2gqVwmCb3m6okdgoCrs8Ljsuxivk_aQnM4B-vCdI3uONUUc8-l-RyzHUOoLKLcrzOFsgxF0k2mJzrDIlOjl86koe3k6j2CfMG-Cb7muUsWoNNu8O2jV3TLP36wywCgwwxxM_g4iuymgaxWyD2xBWX11hz-bat74JWfm',
        reviews: [],
      ),
    ];
  }
}