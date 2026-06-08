import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/network/api_constants.dart';
import 'package:photomanager/core/network/presentation/api_diagnostics_screen.dart';

void main() {
  testWidgets('displays mock API configuration and endpoints', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ApiDiagnosticsScreen()),
      ),
    );

    expect(find.text('API Diagnostics'), findsOneWidget);
    expect(find.text(ApiConstants.baseApiUrl), findsOneWidget);
    expect(find.text(ApiConstants.audioApiUrl), findsOneWidget);
    expect(find.text('MockApiClient'), findsOneWidget);
    expect(find.text(ApiConstants.loginEndpoint), findsOneWidget);
    expect(find.text(ApiConstants.contactsEndpoint), findsOneWidget);
    expect(find.text(ApiConstants.speechToPoseEndpoint), findsOneWidget);
    expect(find.text('Disabled'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Connected'), findsOneWidget);
  });
}
