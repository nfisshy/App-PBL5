import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/app/app.dart';
import 'package:photomanager/core/constants/app_constants.dart';

void main() {
  testWidgets('navigates from splash to login after two seconds',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Login'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('shows an error for invalid credentials', (tester) async {
    await _openLogin(tester);

    await tester.enterText(_emailField, 'admin@test.com');
    await tester.enterText(_passwordField, '654321');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password.'), findsOneWidget);
  });

  testWidgets('navigates to home for valid credentials', (tester) async {
    await _openLogin(tester);

    await tester.enterText(_emailField, 'admin@test.com');
    await tester.enterText(_passwordField, '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.text('Conversation History'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}

Finder get _emailField => find.widgetWithText(TextFormField, 'Email');
Finder get _passwordField => find.widgetWithText(TextFormField, 'Password');

Future<void> _openLogin(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: App()));
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}
