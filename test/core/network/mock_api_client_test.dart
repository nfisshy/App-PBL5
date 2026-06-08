import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/network/api_constants.dart';
import 'package:photomanager/core/network/api_exception.dart';
import 'package:photomanager/core/network/mock_api_client.dart';
import 'package:photomanager/core/network/network_result.dart';

void main() {
  late MockApiClient client;

  setUp(() {
    client = MockApiClient(responseDelay: Duration.zero);
  });

  test('simulates login, contacts, and speech endpoints', () async {
    final login = await client.post<Map<String, Object?>>(
      ApiConstants.loginEndpoint,
      body: const {'email': 'admin@test.com', 'password': '123456'},
      decoder: _map,
    );
    final contacts = await client.get<List<Object?>>(
      ApiConstants.contactsEndpoint,
      decoder: (json) => json as List<Object?>,
    );
    final speech = await client.post<Map<String, Object?>>(
      ApiConstants.speechToPoseEndpoint,
      decoder: _map,
    );

    expect((login as Success).data['user'], isA<Map<String, Object?>>());
    expect((contacts as Success).data, hasLength(4));
    expect((speech as Success).data['final_source'], 'speech');
  });

  test('returns failures for invalid login and unknown endpoints', () async {
    final invalidLogin = await client.post<Object?>(
      ApiConstants.loginEndpoint,
      body: const {'email': 'wrong', 'password': 'wrong'},
    );
    final missing = await client.get<Object?>('/missing');

    expect(invalidLogin, isA<Failure<Object?>>());
    expect(invalidLogin.statusCode, 401);
    expect(missing.statusCode, 404);
  });

  test('converts decoder errors to parsing failures', () async {
    final result = await client.get<int>(
      ApiConstants.contactsEndpoint,
      decoder: (json) => throw const FormatException(),
    );

    expect(result, isA<Failure<int>>());
    expect((result as Failure).exception, isA<ParsingException>());
  });

  test('simulates WAV upload without performing a request', () async {
    final result = await client.upload<Map<String, Object?>>(
      ApiConstants.speechToPoseEndpoint,
      bytes: const [1, 2, 3],
      fileName: 'audio.wav',
      contentType: 'audio/wav',
      decoder: _map,
    );

    expect(result, isA<Success<Map<String, Object?>>>());
    expect((result as Success).data['final_source'], 'speech');
  });
}

Map<String, Object?> _map(Object? json) {
  return Map<String, Object?>.from(json as Map);
}
