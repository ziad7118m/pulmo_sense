import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:lung_diagnosis_app/core/errors/app_exceptions.dart';
import 'package:lung_diagnosis_app/core/failures/failure.dart';
import 'package:lung_diagnosis_app/core/network/network_exceptions.dart';

/// Maps ANY thrown error/exception into a single [AppFailure] model.
///
/// Goal:
/// - Keep try/catch away from UI.
/// - Keep error mapping consistent across the whole app.
class ErrorMapper {
  static AppFailure map(Object error, [StackTrace? stackTrace]) {
    // If the error is already a failure, keep it.
    if (error is AppFailure) {
      return error;
    }

    // App-defined exceptions.
    if (error is AppException) {
      return _mapAppException(error);
    }

    // Dio / networking.
    if (error is DioException) {
      return NetworkExceptions.mapDioError(error);
    }

    // Hive / local cache.
    if (error is HiveError) {
      return AppFailure(
        type: FailureType.cache,
        message: 'Local storage error',
        details: error,
      );
    }

    // Parsing / format.
    if (error is FormatException) {
      return AppFailure(
        type: FailureType.parsing,
        message: error.message.isEmpty ? 'Invalid data format' : error.message,
        details: error,
      );
    }

    // File system (image/audio).
    if (error is FileSystemException) {
      return AppFailure(
        type: FailureType.cache,
        message: 'File system error',
        details: {
          'message': error.message,
          'path': error.path,
          'osError': error.osError?.message,
        },
      );
    }

    // Socket exceptions (no internet etc.).
    if (error is SocketException) {
      return AppFailure(
        type: FailureType.network,
        message: 'No internet connection',
        details: error,
      );
    }

    // Fallback.
    return AppFailure(
      type: FailureType.unknown,
      message: error.toString().trim().isEmpty ? 'Unknown error' : error.toString(),
      details: error,
    );
  }

  static AppFailure _mapAppException(AppException e) {
    if (e is NetworkException) {
      return AppFailure(type: FailureType.network, message: e.message, details: e.details);
    }
    if (e is CacheException) {
      return AppFailure(type: FailureType.cache, message: e.message, details: e.details);
    }
    if (e is ParsingException) {
      return AppFailure(type: FailureType.parsing, message: e.message, details: e.details);
    }
    if (e is ValidationException) {
      return AppFailure(type: FailureType.validation, message: e.message, details: e.details);
    }
    if (e is UnauthorizedException) {
      return AppFailure(type: FailureType.unauthorized, message: e.message, details: e.details);
    }
    if (e is ForbiddenException) {
      return AppFailure(type: FailureType.forbidden, message: e.message, details: e.details);
    }
    if (e is NotFoundException) {
      return AppFailure(type: FailureType.notFound, message: e.message, details: e.details);
    }

    return AppFailure(type: FailureType.unknown, message: e.message, details: e.details);
  }
}
