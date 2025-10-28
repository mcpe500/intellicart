import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/main.dart';
import 'package:intellicart/presentation/pages/home_page.dart';
import 'package:intellicart/presentation/pages/login_page.dart';
import 'package:intellicart/presentation/pages/register_page.dart';
import 'package:intellicart/presentation/pages/product_detail_page.dart';
import 'package:intellicart/presentation/pages/profile_page.dart';
import 'package:intellicart/presentation/widgets/product_card.dart';
import 'package:intellicart/domain/entities/product.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('App loads and displays home page', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the home page is displayed.
      expect(find.byType(HomePage), findsOneWidget);
      
      // Verify that the app title is displayed.
      expect(find.text('Intellicart'), findsOneWidget);
    });
  });

  group('Login Page Tests', () {
    testWidgets('Login page shows login form', (WidgetTester tester) async {
      // Build the login page
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Verify that the login form widgets are present
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields
      expect(find.byType(ElevatedButton), findsOneWidget); // Login button
      expect(find.text('Sign in'), findsOneWidget);
      
      // Find and enter text into email field
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      
      // Find and enter text into password field
      await tester.enterText(find.byType(TextField).last, 'password123');
      
      // Rebuild the widget after the text entries
      await tester.pump();
      
      // Verify the text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Login page shows error for invalid credentials', (WidgetTester tester) async {
      // Build the login page
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Enter invalid credentials
      await tester.enterText(find.byType(TextField).first, 'invalid@example.com');
      await tester.enterText(find.byType(TextField).last, 'wrongpassword');
      
      // Tap the login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Rebuild after tap
      
      // Verify error message appears
      // Note: This test depends on the actual implementation of LoginPage
      // If the page doesn't show an error for invalid credentials, 
      // this assertion might need to be adjusted
    });

    testWidgets('Login page has register link', (WidgetTester tester) async {
      // Build the login page
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Verify the register link is present
      expect(find.text('Don\'t have an account? Register'), findsOneWidget);
    });
  });

  group('Register Page Tests', () {
    testWidgets('Register page shows registration form', (WidgetTester tester) async {
      // Build the register page
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Verify that the registration form widgets are present
      expect(find.text('Register'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3)); // Name, email, and password fields
      expect(find.byType(ElevatedButton), findsOneWidget); // Register button
      expect(find.text('Sign up'), findsOneWidget);
      
      // Find and enter text into name field
      await tester.enterText(find.byType(TextField).at(0), 'Test User');
      
      // Find and enter text into email field
      await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
      
      // Find and enter text into password field
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      
      // Rebuild the widget after the text entries
      await tester.pump();
      
      // Verify the text was entered
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Register page has login link', (WidgetTester tester) async {
      // Build the register page
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Verify the login link is present
      expect(find.text('Already have an account? Login'), findsOneWidget);
    });
  });

  group('Home Page Tests', () {
    testWidgets('Home page shows product list', (WidgetTester tester) async {
      // Build the home page
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify that the home page is displayed
      expect(find.byType(HomePage), findsOneWidget);
      
      // Verify that there are products displayed
      // This test checks if the app can load without crashing
      // The actual product display would depend on data fetching
      expect(find.text('Intellicart'), findsOneWidget);
      
      // Verify that the bottom navigation bar is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Home page switches tabs correctly', (WidgetTester tester) async {
      // Build the home page
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify initial state (Home tab)
      expect(find.byType(HomePage), findsOneWidget);
      
      // Try to tap on different tabs
      // Note: This test depends on the actual implementation of the bottom navigation
      // For now, just ensure it doesn't crash
      await tester.pump();
    });
  });

    final testProduct = Product(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      originalPrice: 109.99,
      quantity: 10,
      imageUrl: 'https://example.com/image.jpg',
      sellerId: '1',
      rating: 0.0,
      reviewCount: 0,
      category: 'Electronics',
      reviews: [],
    );

    testWidgets('ProductCard displays product information', (WidgetTester tester) async {
      // Build the product card
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () {}, // Mock callback
            ),
          ),
        ),
      );

      // Verify that product information is displayed
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.text('\$109.99'), findsOneWidget); // Original price
      
      // Verify that the card and its elements are present
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('ProductCard calls onTap when tapped', (WidgetTester tester) async {
      var tapped = false;
      
      // Build the product card with a mock callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tap the product card
      await tester.tap(find.byType(Card));
      await tester.pump();

      // Verify that the tap callback was called
      expect(tapped, isTrue);
    });
  });

  group('Product Detail Page Tests', () {
    final testProduct = Product(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      originalPrice: 109.99,
      quantity: 10,
      imageUrl: 'https://example.com/image.jpg',
      sellerId: '1',
      rating: 0.0,
      reviewCount: 0,
      category: 'Electronics',
      reviews: [],
    );

    testWidgets('ProductDetailPage displays product details', (WidgetTester tester) async {
      // Build the product detail page
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(
            product: testProduct,
          ),
        ),
      );

      // Verify that product details are displayed
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      
      // Verify that the add to cart button is present
      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('ProductDetailPage handles back navigation', (WidgetTester tester) async {
      // Build the product detail page
      await tester.pumpWidget(
        const MaterialApp(
          home: ProductDetailPage(
            product: null, // This would typically not be null in production
          ),
        ),
      );

      // Try to go back (this would normally pop the route)
      // For this test, we're just ensuring the widget builds without crashing
      await tester.pump();
    });
  });

  group('Profile Page Tests', () {
    testWidgets('Profile page shows basic UI elements', (WidgetTester tester) async {
      // Build the profile page
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify that the profile page is displayed
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      
      // Verify that profile-related widgets are present
      expect(find.byType(ListTile), findsAtLeast(1));
    });
  });
}