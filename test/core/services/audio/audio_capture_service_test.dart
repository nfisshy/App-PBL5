import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/services/audio/audio_capture_service.dart';
import 'package:photomanager/features/audio/data/mock_audio_repository.dart';
import 'package:photomanager/features/audio/domain/audio_capture_state.dart';

void main() {
  test('service delegates recording lifecycle and chunk streams', () async {
    final repository = MockAudioRepository(
      initializationDelay: const Duration(milliseconds: 5),
      chunkInterval: const Duration(milliseconds: 5),
    );
    final service = AudioCaptureService(repository);
    final firstChunk = service.audioChunkStream().first;

    await service.startRecording();
    expect(
        await service.captureStateStream().first, AudioCaptureState.recording);
    expect((await firstChunk).sequenceNumber, 1);

    await service.stopRecording();
    expect(await service.captureStateStream().first, AudioCaptureState.stopped);
    await service.dispose();
  });
}
