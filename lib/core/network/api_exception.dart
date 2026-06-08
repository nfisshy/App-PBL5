sealed class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends ApiException {
  const NetworkException(super.message, {super.statusCode});
}

final class TimeoutException extends ApiException {
  const TimeoutException(super.message, {super.statusCode});
}

final class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});
}

final class ParsingException extends ApiException {
  const ParsingException(super.message, {super.statusCode});
}

final class UnknownException extends ApiException {
  const UnknownException(super.message, {super.statusCode});
}
