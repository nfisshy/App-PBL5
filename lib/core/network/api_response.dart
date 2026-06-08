class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, Object?> json,
    T Function(Object? json) decodeData,
  ) {
    final rawData = json['data'];
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: rawData == null ? null : decodeData(rawData),
    );
  }

  Map<String, Object?> toJson(Object? Function(T data) encodeData) {
    return {
      'success': success,
      'message': message,
      'data': data == null ? null : encodeData(data as T),
    };
  }
}
