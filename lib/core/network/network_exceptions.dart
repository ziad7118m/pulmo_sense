import 'package:dio/dio.dart';
import 'package:lung_diagnosis_app/core/failures/failure.dart';

class NetworkExceptions {
  static AppFailure mapDioError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final path = error.requestOptions.path;
      final serverMessage = _buildServerMessage(error.response?.data);
      final inferredMessage = _inferMessageFromRequestContext(error, serverMessage);
      final resolvedMessage = serverMessage ?? inferredMessage;

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
            message: resolvedMessage ?? 'The submitted data is invalid. Please review the form and try again.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code == 401) {
          return AppFailure(
            type: FailureType.unauthorized,
            message: resolvedMessage ?? 'Unauthorized. Please log in again.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code == 403) {
          return AppFailure(
            type: FailureType.forbidden,
            message: resolvedMessage ?? 'You do not have permission to perform this action.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code == 404) {
          return AppFailure(
            type: FailureType.notFound,
            message: resolvedMessage ?? 'The requested resource was not found.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code == 409) {
          return AppFailure(
            type: FailureType.validation,
            message: resolvedMessage ?? 'This request conflicts with existing data.',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code >= 500) {
          return AppFailure(
            type: FailureType.server,
            message: resolvedMessage ?? _fallback500MessageForPath(path),
            statusCode: code,
            details: error.response?.data,
          );
        }

        return AppFailure(
          type: FailureType.server,
          message: resolvedMessage ?? 'The request failed. Please try again.',
          statusCode: code,
          details: error.response?.data,
        );
      }

      return AppFailure(
        type: FailureType.unknown,
        message: resolvedMessage ?? 'A network error occurred. Please try again.',
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
    final validation = _extractValidationMessage(data);
    if (validation != null && validation.isNotEmpty) {
      return validation;
    }

    final message = _extractServerMessage(data);
    if (message != null && message.isNotEmpty) {
      return _normalizeBackendMessage(message);
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
        return parts.join('\n');
      }
      return null;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final detail = _stringOrNull(map['detail'] ?? map['Detail']);
      final message = _stringOrNull(
        map['message'] ??
            map['Message'] ??
            map['error'] ??
            map['Error'] ??
            map['exceptionMessage'] ??
            map['ExceptionMessage'] ??
            map['description'] ??
            map['Description'],
      );
      final title = _stringOrNull(map['title'] ?? map['Title']);

      if (detail != null && detail.isNotEmpty) return detail;
      if (message != null && message.isNotEmpty) return message;
      if (title != null && title.isNotEmpty) return title;
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
      final key = _prettifyFieldName(entry.key.toString().trim());
      final value = entry.value;

      if (value is List) {
        for (final item in value) {
          final text = _normalizeBackendMessage(item.toString().trim());
          if (text.isEmpty) continue;
          parts.add(key == null ? text : '$key: $text');
        }
        continue;
      }

      final text = _normalizeBackendMessage(value?.toString().trim() ?? '');
      if (text.isEmpty) continue;
      parts.add(key == null ? text : '$key: $text');
    }

    if (parts.isEmpty) return null;
    return parts.join('\n');
  }

  static String? _stringOrNull(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static String? _prettifyFieldName(String raw) {
    if (raw.isEmpty) return null;

    final normalized = raw
        .replaceAll('[', ' ')
        .replaceAll(']', ' ')
        .replaceAll('.', ' ')
        .trim();
    if (normalized.isEmpty) return null;

    const fieldMap = <String, String>{
      'Email': 'Email',
      'Password': 'Password',
      'ConfirmPassword': 'Confirm password',
      'FirstName': 'First name',
      'LastName': 'Last name',
      'NationalId': 'National ID',
      'PhoneNumber': 'Phone number',
      'MedicalLicense': 'Medical license',
      'DateOfBirth': 'Birth date',
      'Code': 'Code',
      'NewPassword': 'New password',
      'UserId': 'User',
      'Title': 'Title',
      'Description': 'Description',
      'Images': 'Images',
      'Image': 'Image',
    };

    if (fieldMap.containsKey(normalized)) {
      return fieldMap[normalized];
    }

    final spaced = normalized
        .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m.group(1)} ${m.group(2)}')
        .replaceAll('_', ' ')
        .trim();
    if (spaced.isEmpty) return null;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  static String _normalizeBackendMessage(String message) {
    final value = message
        .replaceFirst(RegExp(r'^System\.Exception\s*:\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^Exception\s*:\s*', caseSensitive: false), '')
        .trim();
    if (value.isEmpty) return value;

    final lowered = value.toLowerCase();

    const exactMap = <String, String>{
      'invalid email or password': 'Invalid email or password.',
      'invalid eamil or password': 'Invalid email or password.',
      'please verify your email first': 'Please verify your email first.',
      'your account is not approved yet': 'Your account is still pending admin approval.',
      'your account is disabled': 'Your account is disabled.',
      'your account is deleted': 'This account has been deleted.',
      'this account has been deleted': 'This account has been deleted.',
      'your account is rejected': 'Your account has been rejected.',
      'user not found': 'User not found.',
      'user not active': 'This account is not active.',
      'invalid or expired otp': 'Invalid or expired code.',
      'failed to reset password': 'Failed to reset password.',
      'failed to set new password': 'Failed to set the new password.',
      'email already exists.': 'Email already exists.',
      'email already exists': 'Email already exists.',
      "can't create user": 'Unable to create the account.',
      'failed to delete user': 'Failed to update the delete status for this account.',
      'failed to disable user': 'Failed to disable this account.',
      'failed to enable user': 'Failed to enable this account.',
      'user is not pending': 'This account is no longer pending approval.',
      'failed to update user': 'Failed to update this account.',
      'user not authenticated': 'You need to sign in again.',
      'invalid refresh token': 'Your session has expired. Please log in again.',
      'invalid token': 'Invalid token.',
      'post not found': 'Post not found.',
      "you can't delete this post": 'You are not allowed to delete this post.',
      'only doctors can create posts': 'Only doctors can create posts.',
      'maximum allowed images is 3': 'You can upload up to 3 images only.',
      'already added': 'This post is already in favorites.',
      'no favorite posts found': 'No favorite posts found.',
      'favorite not found': 'Favorite not found.',
      'failed to upload image': 'Failed to upload the image.',
      'invalid format': 'Invalid file format.',
    };

    if (exactMap.containsKey(lowered)) {
      return exactMap[lowered]!;
    }

    if (lowered.startsWith('user already in this isdelete = true')) {
      return 'This account is already deleted.';
    }
    if (lowered.startsWith('user already in this isdelete = false')) {
      return 'This account is already restored.';
    }
    if (lowered.startsWith('ai error:')) {
      return 'The AI service is temporarily unavailable. Please try again later.';
    }
    if (lowered.contains('one or more validation errors occurred')) {
      return 'Some fields are invalid. Please review the form and try again.';
    }
    if (lowered.contains('duplicate user name') || lowered.contains('username') && lowered.contains('already')) {
      return 'Username already exists.';
    }
    if (lowered.contains('duplicate email') || lowered.contains('email') && lowered.contains('already')) {
      return 'Email already exists.';
    }
    if (lowered.contains('password') && lowered.contains('too short')) {
      return 'Password is too short.';
    }
    if (lowered.contains('password') && lowered.contains('uppercase')) {
      return 'Password must include at least one uppercase letter.';
    }
    if (lowered.contains('password') && lowered.contains('lowercase')) {
      return 'Password must include at least one lowercase letter.';
    }
    if (lowered.contains('password') && lowered.contains('digit')) {
      return 'Password must include at least one number.';
    }
    if (lowered.contains('password') && lowered.contains('non alphanumeric')) {
      return 'Password must include at least one special character.';
    }

    return value.endsWith('.') ? value : '$value.';
  }

  static String? _inferMessageFromRequestContext(DioException error, String? serverMessage) {
    if (serverMessage != null && serverMessage.isNotEmpty) return null;

    final path = error.requestOptions.path.toLowerCase();
    final method = error.requestOptions.method.toUpperCase();
    final status = error.response?.statusCode;

    if (status == 500) {
      if (path.contains('/authentication/login')) {
        return 'No account is registered with this email address, or the password is incorrect.';
      }
      if (path.contains('/authentication/refresh-token')) {
        return 'Your session has expired. Please log in again.';
      }
      if (path.contains('/authentication/forget-password') || path.contains('/authentication/forgot-password')) {
        return 'No account is registered with this email address.';
      }
      if (path.contains('/authentication/verify-otp') || path.contains('/authentication/reset-password')) {
        return 'Invalid or expired code.';
      }
      if (path.contains('/posts') && method == 'POST') {
        return 'Failed to create the post. Please review the data and try again.';
      }
      if (path.contains('/posts') && method == 'PUT') {
        return 'Failed to update the post. Please try again.';
      }
      if (path.contains('/xray') || path.contains('/ai')) {
        return 'The AI service is temporarily unavailable. Please try again later.';
      }
    }

    return null;
  }

  static String _fallback500MessageForPath(String path) {
    final lowered = path.toLowerCase();
    if (lowered.contains('/authentication/')) {
      return 'Authentication failed. Please verify your data and try again.';
    }
    if (lowered.contains('/admin/')) {
      return 'Failed to load admin data. Please try again.';
    }
    if (lowered.contains('/posts')) {
      return 'Failed to process the post request. Please try again.';
    }
    if (lowered.contains('/profile')) {
      return 'Failed to load the profile. Please try again.';
    }
    if (lowered.contains('/ai') || lowered.contains('/xray')) {
      return 'The AI service is temporarily unavailable. Please try again later.';
    }
    return 'The server encountered an error while processing the request.';
  }
}
