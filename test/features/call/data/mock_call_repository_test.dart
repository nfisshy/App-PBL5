import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/call/data/mock_call_repository.dart';

void main() {
  group('MockCallRepository', () {
    test('returns participant and translated messages for a known username',
        () async {
      final repository = MockCallRepository();

      final state = await repository.getCallState('dat');

      expect(state, isNotNull);
      expect(state!.participant.username, 'dat');
      expect(state.participant.displayName, 'Nguyen Tien Dat');
      expect(state.messages, hasLength(3));
      expect(state.messages.first.sender, 'HUY');
      expect(state.messages.first.text, 'Xin chào');
      expect(state.isMicEnabled, isTrue);
    });

    test('returns null for an unknown username', () async {
      final repository = MockCallRepository();

      final state = await repository.getCallState('unknown');

      expect(state, isNull);
    });
  });
}
