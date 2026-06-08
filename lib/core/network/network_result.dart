sealed class NetworkResult<T> {
  const NetworkResult({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final int? statusCode;

  T? get data;

  bool get isSuccess => this is Success<T>;
}

final class Success<T> extends NetworkResult<T> {
  const Success({
    required this.data,
    required super.message,
    required super.statusCode,
  });

  @override
  final T data;
}

final class Failure<T> extends NetworkResult<T> {
  const Failure({
    required super.message,
    required super.statusCode,
    this.exception,
    this.data,
  });

  final Object? exception;

  @override
  final T? data;
}
