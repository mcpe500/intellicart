// lib/data/datasources/mock_backend.dart
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/models/review.dart';
import 'package:intellicart_frontend/models/user.dart';
import 'package:intellicart_frontend/models/order.dart';

class MockBackend {
  // Mock data stores
  // Private user data storage - users can only see their own data
  static List<User> _users = [
    User(
      id: '1',
      email: 'buyer@example.com',
      name: 'John Buyer',
      role: 'buyer',
    ),
    User(
      id: '2',
      email: 'seller@example.com',
      name: 'Jane Seller',
      role: 'seller',
    ),
  ];
  
  // Password storage (in real app, use hashed passwords)
  static Map<String, String> _passwords = {
    'buyer@example.com': 'password123',
    'seller@example.com': 'password123',
  };

  static List<Product> _products = [
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
          'https://example.com/speaker-image.jpg', // Using a shorter placeholder URL
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

  static List<Order> _orders = [
    Order(
      id: '1',
      customerName: 'John Doe',
      total: 129.98,
      status: 'Delivered',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      items: [
        // Using actual Product objects from our product list
        _products.firstWhere((p) => p.name == 'Stylish Headphones', orElse: () => _products[0]),
        _products.firstWhere((p) => p.name == 'Wireless Earbuds', orElse: () => _products[1]),
      ],
    ),
    Order(
      id: '2',
      customerName: 'Jane Smith',
      total: 199.99,
      status: 'Shipped',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      items: [
        _products.firstWhere((p) => p.name == 'Smartwatch Series 7', orElse: () => _products[2]),
      ],
    ),
  ];

  // --- AUTHENTICATION METHODS ---
  Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check if user exists
    final user = _users.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );
    
    // Verify password
    final storedPassword = _passwords[email];
    if (storedPassword != password) {
      throw Exception('Invalid password');
    }
    
    // Return user without sensitive data (in real app, return a token instead)
    return User(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
    );
  }

  Future<User> register(String email, String password, String name, String role) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Validate inputs
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('All fields are required');
    }
    
    // Check if user already exists
    if (_users.any((user) => user.email == email)) {
      throw Exception('User already exists');
    }
    
    // Create new user
    final newUser = User(
      id: (_users.length + 1).toString(),
      email: email,
      name: name,
      role: role,
    );
    
    _users.add(newUser);
    _passwords[email] = password; // Store password (in real app, hash it)
    return newUser;
  }

  // --- PRODUCT METHODS ---
  Future<List<Product>> fetchProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return [..._products]; // Return a copy to prevent direct modification
  }

  Future<Product> addProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newProduct = Product(
      name: product.name,
      description: product.description,
      price: product.price,
      originalPrice: product.originalPrice,
      imageUrl: product.imageUrl,
      reviews: product.reviews,
    );
    
    _products.add(newProduct);
    return newProduct;
  }

  Future<Product> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _products.indexWhere((p) => p.name == product.name);
    if (index != -1) {
      _products[index] = product;
      return product;
    }
    
    throw Exception('Product not found');
  }

  Future<void> deleteProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _products.removeWhere((p) => p.name == product.name);
  }

  Future<List<Product>> fetchSellerProducts(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would filter by sellerId
    // For mock: add a sellerId property to products and filter
    // For now, return products that are associated with this seller (mock implementation)
    return [..._products];
  }

  // --- ORDER METHODS ---
  Future<List<Order>> fetchSellerOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would filter by the authenticated seller
    // For mock: return all orders as seller orders
    return [..._orders];
  }
  
  // Method to fetch user-specific data securely
  Future<User?> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final user = _users.firstWhere(
      (user) => user.id == userId,
      orElse: () => throw Exception('User not found'),
    );
    
    // Return only non-sensitive user data
    return User(
      id: user.id,
      email: user.email,  // In real app, you might only return this for the authenticated user
      name: user.name,
      role: user.role,
    );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _orders[index] = Order(
        id: _orders[index].id,
        customerName: _orders[index].customerName,
        items: _orders[index].items,
        total: _orders[index].total,
        status: status,
        orderDate: _orders[index].orderDate,
      );
    }
  }
}
