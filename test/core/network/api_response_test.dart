import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/network/api_response.dart';

void main() {
  test('generic API response decodes and encodes data', () {
    final response = ApiResponse<int>.fromJson(
      const {'success': true, 'message': 'ok', 'data': '4'},
      (json) => int.parse(json as String),
    );

    expect(response.success, isTrue);
    expect(response.data, 4);
    expect(response.toJson((data) => '$data'), {
      'success': true,
      'message': 'ok',
      'data': '4',
    });
  });
}
