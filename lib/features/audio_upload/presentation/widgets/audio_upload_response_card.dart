import 'package:flutter/material.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_response.dart';

class AudioUploadResponseCard extends StatelessWidget {
  const AudioUploadResponseCard({
    required this.response,
    super.key,
  });

  final AudioUploadResponse? response;

  @override
  Widget build(BuildContext context) {
    final latestResponse = response;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: latestResponse == null
            ? const Text('No upload response yet.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Response',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Draft: ${latestResponse.draftText}'),
                  Text('Final: ${latestResponse.finalText}'),
                  Text('Source: ${latestResponse.finalSource}'),
                ],
              ),
      ),
    );
  }
}
