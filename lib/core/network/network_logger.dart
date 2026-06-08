abstract interface class NetworkLogger {
  void logRequest({
    required String method,
    required String path,
    Object? body,
  });

  void logResponse({
    required String method,
    required String path,
    required int statusCode,
    Object? body,
  });

  void logError({
    required String method,
    required String path,
    required Object error,
  });
}

class NoOpNetworkLogger implements NetworkLogger {
  const NoOpNetworkLogger();

  @override
  void logRequest(
      {required String method, required String path, Object? body}) {}

  @override
  void logResponse({
    required String method,
    required String path,
    required int statusCode,
    Object? body,
  }) {}

  @override
  void logError({
    required String method,
    required String path,
    required Object error,
  }) {}
}
