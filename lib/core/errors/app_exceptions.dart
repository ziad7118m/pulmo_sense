/// App-level exceptions that can be thrown from data-sources.
///
/// We prefer returning [Result] from repositories, but sometimes lower layers
/// (Hive, file IO, parsing, etc.) may throw. These exceptions help us
/// classify errors before mapping them to [AppFailure].
sealed class AppException implements Exception {
  final String message;
  final Object? details;

  const AppException(this.message, [this.details]);

  @override
  String toString() => '$runtimeType(message: $message, details: $details)';
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.details]);
}

class CacheException extends AppException {
  const CacheException(super.message, [super.details]);
}

class ParsingException extends AppException {
  const ParsingException(super.message, [super.details]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.details]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, [super.details]);
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message, [super.details]);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.details]);
}
