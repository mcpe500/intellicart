import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/presentation/screens/buyer/order_tracking_page.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('OrderTrackingPage renders title and segments', (tester) async {
    await tester.pumpWidget(wrap(const OrderTrackingPage()));

    expect(find.text('Order Tracking'), findsOneWidget);
    expect(find.text('Active Orders'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Canceled'), findsOneWidget);
  });

  testWidgets('Search filters orders', (tester) async {
    await tester.pumpWidget(wrap(const OrderTrackingPage()));

    await tester.enterText(find.byType(TextField), 'XYZ123');
    await tester.pumpAndSettle();

    expect(find.textContaining('Order #XYZ123'), findsOneWidget);
    expect(find.textContaining('Order #ABC456'), findsNothing);
  });

  testWidgets('Segments filter orders', (tester) async {
    await tester.pumpWidget(wrap(const OrderTrackingPage()));

    // Completed: should not show active packaged order XYZ123
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Order #DEF789'), findsOneWidget); // Done
    expect(find.textContaining('Order #ABC456'), findsNothing);   // Sent is active

    // Canceled: should show GHI012
    await tester.tap(find.text('Canceled'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Order #GHI012'), findsOneWidget);
    expect(find.textContaining('Order #DEF789'), findsNothing);
  });
}
