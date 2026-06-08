import 'package:photomanager/core/network/api_client.dart';
import 'package:photomanager/core/network/api_constants.dart';
import 'package:photomanager/core/network/network_result.dart';
import 'package:photomanager/features/auth/data/dtos/login_request_dto.dart';
import 'package:photomanager/features/auth/data/dtos/login_response_dto.dart';
import 'package:photomanager/features/contacts/data/dtos/contact_dto.dart';
import 'package:photomanager/features/speech_output/data/dtos/speech_request_dto.dart';
import 'package:photomanager/features/speech_output/data/dtos/speech_response_dto.dart';

class ApiService {
  const ApiService(this._client);

  final ApiClient _client;

  Future<NetworkResult<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    ResponseDecoder<T>? decoder,
  }) {
    return _client.get(
      path,
      queryParameters: queryParameters,
      decoder: decoder,
    );
  }

  Future<NetworkResult<T>> post<T>(
    String path, {
    Object? body,
    ResponseDecoder<T>? decoder,
  }) {
    return _client.post(path, body: body, decoder: decoder);
  }

  Future<NetworkResult<T>> put<T>(
    String path, {
    Object? body,
    ResponseDecoder<T>? decoder,
  }) {
    return _client.put(path, body: body, decoder: decoder);
  }

  Future<NetworkResult<T>> delete<T>(
    String path, {
    Object? body,
    ResponseDecoder<T>? decoder,
  }) {
    return _client.delete(path, body: body, decoder: decoder);
  }

  Future<NetworkResult<T>> upload<T>(
    String path, {
    required List<int> bytes,
    required String fileName,
    required String contentType,
    Map<String, Object?>? fields,
    ResponseDecoder<T>? decoder,
  }) {
    return _client.upload(
      path,
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
      fields: fields,
      decoder: decoder,
    );
  }

  Future<NetworkResult<LoginResponseDto>> login(LoginRequestDto request) {
    return post(
      ApiConstants.loginEndpoint,
      body: request.toJson(),
      decoder: (json) => LoginResponseDto.fromJson(_jsonMap(json)),
    );
  }

  Future<NetworkResult<List<ContactDto>>> getContacts() {
    return get(
      ApiConstants.contactsEndpoint,
      decoder: (json) => (json as List<Object?>)
          .map((item) => ContactDto.fromJson(_jsonMap(item)))
          .toList(growable: false),
    );
  }

  Future<NetworkResult<SpeechResponseDto>> processSpeech(
    SpeechRequestDto request,
  ) {
    return post(
      ApiConstants.speechToPoseEndpoint,
      body: request.toJson(),
      decoder: (json) => SpeechResponseDto.fromJson(_jsonMap(json)),
    );
  }

  Future<NetworkResult<SpeechResponseDto>> uploadWav({
    required List<int> bytes,
    required SpeechRequestDto request,
  }) {
    return upload(
      ApiConstants.speechToPoseEndpoint,
      bytes: bytes,
      fileName: 'audio.wav',
      contentType: 'audio/wav',
      fields: request.toJson(),
      decoder: (json) => SpeechResponseDto.fromJson(_jsonMap(json)),
    );
  }
}

Map<String, Object?> _jsonMap(Object? json) {
  return Map<String, Object?>.from(json as Map);
}
