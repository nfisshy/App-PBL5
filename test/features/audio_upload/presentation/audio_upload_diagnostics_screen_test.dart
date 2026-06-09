import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/network/api_constants.dart';
import 'package:photomanager/features/audio_upload/presentation/audio_upload_diagnostics_screen.dart';

void main() {
  testWidgets('displays upload configuration, state, and controls',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AudioUploadDiagnosticsScreen()),
      ),
    );

    expect(find.text('Audio Upload Diagnostics'), findsOneWidget);
    expect(find.text('Current Upload State'), findsOneWidget);
    expect(
      find.text(
        'Endpoint: ${ApiConstants.audioApiUrl}'
        '${ApiConstants.speechToPoseRawEndpoint}',
      ),
      findsOneWidget,
    );
    expect(find.text('Language: vi'), findsOneWidget);
    expect(find.text('Mock Upload Audio'), findsOneWidget);
    expect(find.text('Generate Mock Response'), findsOneWidget);
    expect(find.text('No upload response yet.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
