import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/core/network/api_constants.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_state.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_statistics.dart';
import 'package:photomanager/features/audio_upload/presentation/audio_upload_providers.dart';
import 'package:photomanager/features/audio_upload/presentation/widgets/audio_upload_control_panel.dart';
import 'package:photomanager/features/audio_upload/presentation/widgets/audio_upload_response_card.dart';
import 'package:photomanager/features/audio_upload/presentation/widgets/audio_upload_statistics_card.dart';
import 'package:photomanager/features/audio_upload/presentation/widgets/audio_upload_status_badge.dart';

class AudioUploadDiagnosticsScreen extends ConsumerWidget {
  const AudioUploadDiagnosticsScreen({super.key});

  static const language = 'vi';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioUploadStateProvider).valueOrNull ??
        AudioUploadState.idle;
    final statistics = ref.watch(audioUploadStatisticsProvider).valueOrNull ??
        const AudioUploadStatistics.empty();
    final response = ref.watch(audioUploadResponseProvider).valueOrNull;
    final service = ref.read(audioUploadServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Audio Upload Diagnostics')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Current Upload State',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            AudioUploadStatusBadge(state: state),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const SelectableText(
                          'Endpoint: ${ApiConstants.audioApiUrl}'
                          '${ApiConstants.speechToPoseRawEndpoint}',
                        ),
                        const Text('Language: $language'),
                        const Text('Content-Type: audio/wav'),
                        const Text('Accept-Encoding: gzip'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AudioUploadStatisticsCard(statistics: statistics),
                const SizedBox(height: 12),
                AudioUploadResponseCard(response: response),
                const SizedBox(height: 12),
                AudioUploadControlPanel(
                  state: state,
                  onUpload: () => service.uploadAudio(
                    language: language,
                    audioBytesLength: 32000,
                  ),
                  onCancel: service.cancelUpload,
                  onGenerateResponse: service.generateMockResponse,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
