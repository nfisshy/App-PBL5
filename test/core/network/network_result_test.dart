import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/network/api_exception.dart';
import 'package:photomanager/core/network/network_result.dart';

void main() {
  test('success exposes data, message, and status code', () {
    const result = Success(
      data: 'payload',
      message: 'ok',
      statusCode: 200,
    );

    expect(result.data, 'payload');
    expect(result.message, 'ok');
    expect(result.statusCode, 200);
    expect(result.isSuccess, isTrue);
  });

  test('failure exposes message, status code, and exception', () {
    const exception = ServerException('failed', statusCode: 500);
    const result = Failure<String>(
      message: 'failed',
      statusCode: 500,
      exception: exception,
    );

    expect(result.data, isNull);
    expect(result.exception, exception);
    expect(result.isSuccess, isFalse);
  });

  test('exception hierarchy preserves messages and status codes', () {
    const exceptions = <ApiException>[
      NetworkException('offline'),
      TimeoutException('slow'),
      ServerException('server', statusCode: 503),
      ParsingException('invalid'),
      UnknownException('unknown'),
    ];

    expect(exceptions.map((exception) => exception.message), [
      'offline',
      'slow',
      'server',
      'invalid',
      'unknown',
    ]);
    expect(exceptions[2].statusCode, 503);
  });
}
