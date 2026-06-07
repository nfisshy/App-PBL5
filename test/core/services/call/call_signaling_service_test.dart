import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/services/call/call_signaling_service.dart';
import 'package:photomanager/features/call/data/signaling/mock_call_signaling_repository.dart';
import 'package:photomanager/features/call/domain/signaling/call_status.dart';

void main() {
  test('service delegates outgoing call signaling', () async {
    final service = CallSignalingService(
      MockCallSignalingRepository(
        transitionDelay: const Duration(milliseconds: 5),
      ),
    );
    final accepted = service
        .callStatusStream()
        .firstWhere((status) => status == CallStatus.accepted);

    await service.startCall(
      callerUsername: 'huy',
      callerDisplayName: 'HUY',
      receiverUsername: 'dat',
      receiverDisplayName: 'Nguyen Tien Dat',
    );

    expect(await accepted, CallStatus.accepted);
  });
}
