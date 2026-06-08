abstract interface class ApiInterceptor {
  Future<Object?> onRequest({
    required String method,
    required String path,
    Object? body,
  });

  Future<Object?> onResponse({
    required String method,
    required String path,
    required int statusCode,
    Object? body,
  });

  Future<Object> onError({
    required String method,
    required String path,
    required Object error,
  });
}
