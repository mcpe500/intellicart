import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/presentation/screens/core/register_page.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('RegisterPage renders inputs and button', (tester) async {
    await tester.pumpWidget(wrap(const RegisterPage()));

    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byKey(const Key('create_account_button')), findsOneWidget);
  });
}
