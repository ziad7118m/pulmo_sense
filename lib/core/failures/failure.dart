/// Failure موحد لكل التطبيق.
/// بدل ما كل repo يرمي Exception مختلف، كله يرجع AppFailure.

enum FailureType {
  network,
  timeout,
  server,
  unauthorized,
  forbidden,
  notFound,
  validation,
  parsing,
  cache,
  unknown,
}

class AppFailure {
  final FailureType type;
  final String message;

  /// HTTP status code (لو موجود)
  final int? statusCode;

  /// تفاصيل مفيدة للتصحيح (مش للـ UI)
  final Object? details;

  const AppFailure({
    required this.type,
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() =>
      'AppFailure(type: $type, statusCode: $statusCode, message: $message, details: $details)';
}
