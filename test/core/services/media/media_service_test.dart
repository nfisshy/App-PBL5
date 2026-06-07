import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/services/media/media_service.dart';
import 'package:photomanager/features/media/data/mock_media_repository.dart';
import 'package:photomanager/features/media/domain/media_connection_state.dart';

void main() {
  test('service delegates camera and stream operations', () async {
    final service = MediaService(
      MockMediaRepository(
        initializationDelay: const Duration(milliseconds: 5),
      ),
    );

    await service.enableCamera();
    expect((await service.cameraStateStream().first).isEnabled, isTrue);

    await service.startVideoStream();
    expect(
      (await service.videoStreamStateStream().first).connectionState,
      MediaConnectionState.streaming,
    );

    await service.stopVideoStream();
    expect((await service.videoStreamStateStream().first).isStreaming, isFalse);
  });
}
