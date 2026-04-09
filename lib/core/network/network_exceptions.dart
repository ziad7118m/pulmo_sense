import 'package:dio/dio.dart';
import 'package:lung_diagnosis_app/core/failures/failure.dart';

class NetworkExceptions {
  static AppFailure mapDioError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final serverMessage = _buildServerMessage(error.response?.data);

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return AppFailure(
          type: FailureType.timeout,
          message: 'The request timed out. Please try again.',
          statusCode: status,
          details: error,
        );
      }

      if (error.type == DioExceptionType.cancel) {
        return AppFailure(
          type: FailureType.network,
          message: 'The request was cancelled.',
          statusCode: status,
          details: error,
        );
      }

      if (error.type == DioExceptionType.connectionError) {
        return AppFailure(
          type: FailureType.network,
          message: 'No internet connection. Please check your network and try again.',
          statusCode: status,
          details: error,
        );
      }

      if (error.type == DioExceptionType.badResponse) {
        final code = status ?? -1;

        if (code == 400 || code == 422) {
          return AppFailure(
            type: FailureType.validation,
            message: serverMessage ?? 'The submitted data is invalid. Please review the form and try again.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code == 401) {
          return AppFailure(
            type: FailureType.unauthorized,
            message: serverMessage ?? 'Unauthorized. Please log in again.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code == 403) {
          return AppFailure(
            type: FailureType.forbidden,
            message: serverMessage ?? 'You do not have permission to perform this action.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code == 404) {
          return AppFailure(
            type: FailureType.notFound,
            message: serverMessage ?? 'The requested resource was not found.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code == 409) {
          return AppFailure(
            type: FailureType.validation,
            message: serverMessage ?? 'This request conflicts with existing data.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code >= 500) {
          return AppFailure(
            type: FailureType.server,
            message: serverMessage ?? 'The server encountered an error while processing the request.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        return AppFailure(
          type: FailureType.server,
          message: serverMessage ?? 'The request failed. Please try again.',
          statusCode: code,
          details: error.response?.data,
        );
      }

      return AppFailure(
        type: FailureType.unknown,
        message: serverMessage ?? 'A network error occurred. Please try again.',
        statusCode: status,
        details: error,
      );
    }

    return AppFailure(
      type: FailureType.unknown,
      message: 'An unexpected error occurred.',
      details: error,
    );
  }

  static String? _buildServerMessage(dynamic data) {
    final message = _extractServerMessage(data);
    if (message != null && message.isNotEmpty) {
      return message;
    }

    final validation = _extractValidationMessage(data);
    if (validation != null && validation.isNotEmpty) {
      return validation;
    }

    return null;
  }

  static String? _extractServerMessage(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      final value = data.trim();
      if (value.isEmpty) return null;
      if (value.startsWith('<!DOCTYPE html') || value.startsWith('<html')) {
        return null;
      }
      return value;
    }

    if (data is List) {
      final parts = data
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
      if (parts.isNotEmpty) {
        return parts.join('');
      }
      return null;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final candidates = [
        map['message'],
        map['Message'],
        map['title'],
        map['Title'],
        map['detail'],
        map['Detail'],
        map['error'],
        map['Error'],
        map['exceptionMessage'],
        map['ExceptionMessage'],
      ];
      for (final candidate in candidates) {
        final value = candidate?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }

    return null;
  }

  static String? _extractValidationMessage(dynamic data) {
    if (data is! Map) return null;

    final map = Map<String, dynamic>.from(data);
    final errors = map['errors'] ?? map['Errors'];
    if (errors is! Map) return null;

    final parts = <String>[];
    for (final entry in errors.entries) {
      final key = entry.key.toString().trim();
      final value = entry.value;

      if (value is List) {
        for (final item in value) {
          final text = item.toString().trim();
          if (text.isEmpty) continue;
          if (key.isEmpty) {
            parts.add(text);
          } else {
            parts.add('$key: $text');
          }
        }
        continue;
      }

      final text = value?.toString().trim() ?? '';
      if (text.isEmpty) continue;
      if (key.isEmpty) {
        parts.add(text);
      } else {
        parts.add('$key: $text');
      }
    }

    if (parts.isEmpty) return null;
    return parts.join('');
  }
}
