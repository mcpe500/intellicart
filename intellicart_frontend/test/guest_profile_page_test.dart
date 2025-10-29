import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/presentation/screens/core/guest_profile_page.dart';

void main() {
  testWidgets('GuestProfilePage shows CTA and benefits', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GuestProfilePage()));

    expect(find.text('Guest Profile'), findsOneWidget);
    expect(find.text('You are browsing as a Guest'), findsOneWidget);
    expect(find.text('Welcome to Intellicart!'), findsOneWidget);

    // CTAs
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an Account'), findsOneWidget);

    // Benefits
    expect(find.text('Benefits of creating an account:'), findsOneWidget);
    expect(find.text('Save your favorites'), findsOneWidget);
    expect(find.text('Track your orders'), findsOneWidget);
    expect(find.text('Faster checkout'), findsOneWidget);
  });
}
