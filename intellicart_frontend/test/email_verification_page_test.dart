import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/presentation/screens/core/email_verification_page.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('EmailVerificationPage shows instructions and buttons', (tester) async {
    await tester.pumpWidget(wrap(const EmailVerificationPage(email: 'user@example.com')));

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.textContaining('user@example.com'), findsOneWidget);
    expect(find.text('Open email app'), findsOneWidget);
    expect(find.text('Resend email'), findsOneWidget);
  });
}
