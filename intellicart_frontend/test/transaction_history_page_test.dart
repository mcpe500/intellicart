import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/presentation/screens/buyer/transaction_history_page.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('TransactionHistoryPage renders title and filters', (tester) async {
    await tester.pumpWidget(wrap(const TransactionHistoryPage()));

    expect(find.text('Transaction History'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Purchases'), findsOneWidget);
    expect(find.text('Refunds'), findsOneWidget);
    expect(find.text('Top-ups'), findsOneWidget);
  });

  testWidgets('Search filters transactions', (tester) async {
    await tester.pumpWidget(wrap(const TransactionHistoryPage()));

    // Enter a query that matches only the top-up item
    final field = find.byType(TextField);
    await tester.enterText(field, 'Wallet');
    await tester.pumpAndSettle();

    expect(find.textContaining('Wallet Top-up'), findsOneWidget);
    expect(find.textContaining('Order #ABCDEF'), findsNothing);
  });

  testWidgets('Segmented control filters to Refunds', (tester) async {
    await tester.pumpWidget(wrap(const TransactionHistoryPage()));

    await tester.tap(find.text('Refunds'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Refund for Item XYZ'), findsOneWidget);
    expect(find.textContaining('Wallet Top-up'), findsNothing);
    expect(find.textContaining('Order #'), findsNothing);
  });
}
