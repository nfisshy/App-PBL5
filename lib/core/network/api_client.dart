import 'package:photomanager/core/network/network_result.dart';

typedef ResponseDecoder<T> = T Function(Object? json);

abstract interface class ApiClient {
  Future<NetworkResult<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    ResponseDecoder<T>? decoder,
  });

  Future<NetworkResult<T>> post<T>(
    String path, {
    Object? body,
    ResponseDecoder<T>? decoder,
  });

  Future<NetworkResult<T>> put<T>(
    String path, {
    Object? body,
    ResponseDecoder<T>? decoder,
  });

  Future<NetworkResult<T>> delete<T>(
    String path, {
    Object? body,
    ResponseDecoder<T>? decoder,
  });

  Future<NetworkResult<T>> upload<T>(
    String path, {
    required List<int> bytes,
    required String fileName,
    required String contentType,
    Map<String, Object?>? fields,
    ResponseDecoder<T>? decoder,
  });
}
