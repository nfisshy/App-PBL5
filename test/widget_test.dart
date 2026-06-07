import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/app/app.dart';
import 'package:photomanager/core/constants/app_constants.dart';

void main() {
  testWidgets('shows the splash screen initially', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);
  });
}
