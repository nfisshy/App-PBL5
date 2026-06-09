import 'package:photomanager/core/network/api_client.dart';
import 'package:photomanager/core/network/api_constants.dart';
import 'package:photomanager/core/network/api_exception.dart';
import 'package:photomanager/core/network/network_logger.dart';
import 'package:photomanager/core/network/network_result.dart';

class MockApiClient implements ApiClient {
  MockApiClient({
    this.responseDelay = const Duration(milliseconds: 300),
    NetworkLogger logger = const NoOpNetworkLogger(),
  }) : _logger = logger;

  final Duration responseDelay;
  final NetworkLogger _logger;

  @override
  Future<NetworkResult<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    ResponseDecoder<T>? decoder,
  }) {
    return _handle(
      method: 'GET',
      path: path,
      decoder: decoder,
      response: switch (path) {
        ApiConstants.contactsEndpoint => const _MockResponse(
            statusCode: 200,
            message: 'Contacts loaded.',
            data: _contacts,
          ),
        _ => _notFound(path),
      },
    );
  }

  @override
  Future<NetworkResult<T>> post<T>(
    String path, {
    Object? body,
    ResponseDecoder<T>? decoder,
  }) {
    final response = switch (path) {
      ApiConstants.loginEndpoint => _loginResponse(body),
      ApiConstants.speechToPoseEndpoint => const _MockResponse(
          statusCode: 200,
          message: 'Speech processed.',
          data: {
            'draft_text': 'Xin chao',
            'final_text': 'Xin chao ban',
            'final_source': 'speech',
          },
        ),
      _ => _notFound(path),
    };
    return _handle(
      method: 'POST',
      path: path,
      body: body,
      decoder: decoder,
      response: response,
    );
  }

  @override
  Future<NetworkResult<T>> put<T>(
    String path, {
    Object? body,
    ResponseDecoder<T>? decoder,
  }) {
    return _handle(
      method: 'PUT',
      path: path,
      body: body,
      decoder: decoder,
      response: _notFound(path),
    );
  }

  @override
  Future<NetworkResult<T>> delete<T>(
    String path, {
    Object? body,
    ResponseDecoder<T>? decoder,
  }) {
    return _handle(
      method: 'DELETE',
      path: path,
      body: body,
      decoder: decoder,
      response: _notFound(path),
    );
  }

  @override
  Future<NetworkResult<T>> upload<T>(
    String path, {
    required List<int> bytes,
    required String fileName,
    required String contentType,
    Map<String, Object?>? fields,
    ResponseDecoder<T>? decoder,
  }) {
    if (path != ApiConstants.speechToPoseEndpoint &&
        path != ApiConstants.speechToPoseRawEndpoint) {
      return _handle(
        method: 'UPLOAD',
        path: path,
        body: fields,
        decoder: decoder,
        response: _notFound(path),
      );
    }
    return _handle(
      method: 'UPLOAD',
      path: path,
      body: fields,
      decoder: decoder,
      response: const _MockResponse(
        statusCode: 200,
        message: 'Mock WAV upload processed.',
        data: {
          'draft_text': 'Ban nhap tu tep WAV',
          'final_text': 'Ket qua tu tep WAV',
          'final_source': 'speech',
        },
      ),
    );
  }

  Future<NetworkResult<T>> _handle<T>({
    required String method,
    required String path,
    required _MockResponse response,
    Object? body,
    ResponseDecoder<T>? decoder,
  }) async {
    _logger.logRequest(method: method, path: path, body: body);
    await Future<void>.delayed(responseDelay);

    if (response.statusCode >= 400) {
      final exception = ServerException(
        response.message,
        statusCode: response.statusCode,
      );
      _logger.logError(method: method, path: path, error: exception);
      return Failure(
        message: response.message,
        statusCode: response.statusCode,
        exception: exception,
      );
    }

    try {
      final data =
          decoder == null ? response.data as T : decoder(response.data);
      _logger.logResponse(
        method: method,
        path: path,
        statusCode: response.statusCode,
        body: response.data,
      );
      return Success(
        data: data,
        message: response.message,
        statusCode: response.statusCode,
      );
    } on Object catch (error) {
      const exception = ParsingException('Unable to decode mock response.');
      _logger.logError(method: method, path: path, error: error);
      return Failure(
        message: exception.message,
        statusCode: response.statusCode,
        exception: exception,
      );
    }
  }

  _MockResponse _loginResponse(Object? body) {
    final json =
        body is Map<String, Object?> ? body : const <String, Object?>{};
    if (json['email'] == 'admin@test.com' && json['password'] == '123456') {
      return const _MockResponse(
        statusCode: 200,
        message: 'Login successful.',
        data: {
          'user': {
            'email': 'admin@test.com',
            'username': 'Admin',
          },
        },
      );
    }
    return const _MockResponse(
      statusCode: 401,
      message: 'Invalid email or password.',
    );
  }

  _MockResponse _notFound(String path) {
    return _MockResponse(
      statusCode: 404,
      message: 'Mock endpoint not found: $path',
    );
  }
}

class _MockResponse {
  const _MockResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  final int statusCode;
  final String message;
  final Object? data;
}

const _contacts = [
  {'username': 'dat', 'display_name': 'Nguyen Tien Dat'},
  {'username': 'linh', 'display_name': 'Tran Thi Linh'},
  {'username': 'an', 'display_name': 'Le Van An'},
  {'username': 'minh', 'display_name': 'Pham Duc Minh'},
];
