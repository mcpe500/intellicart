import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/presentation/screens/seller/seller_order_management_page.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('SellerOrderManagementPage shows title, search, and tabs', (tester) async {
    await tester.pumpWidget(wrap(const SellerOrderManagementPage()));

    expect(find.text('Order Management'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Incoming'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('Search filters by ID and name', (tester) async {
    await tester.pumpWidget(wrap(const SellerOrderManagementPage()));

    // Search by order ID
    await tester.enterText(find.byType(TextField), 'IC-12345');
    await tester.pumpAndSettle();
    expect(find.textContaining('IC-12345'), findsOneWidget);
    expect(find.textContaining('IC-12344'), findsNothing);

    // Search by buyer name
    await tester.enterText(find.byType(TextField), 'Jane');
    await tester.pumpAndSettle();
    expect(find.textContaining('Jane Smith'), findsOneWidget);
    expect(find.textContaining('John Doe'), findsNothing);
  });

  testWidgets('Tabs filter lists', (tester) async {
    await tester.pumpWidget(wrap(const SellerOrderManagementPage()));

    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    expect(find.textContaining('IC-11888'), findsOneWidget);
    expect(find.textContaining('IC-12345'), findsNothing);

    await tester.tap(find.text('Pending'));
    await tester.pumpAndSettle();
    expect(find.textContaining('IC-12001'), findsOneWidget);
    expect(find.textContaining('IC-11888'), findsNothing);
  });
}
