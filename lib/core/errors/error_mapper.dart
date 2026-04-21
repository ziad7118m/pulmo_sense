import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lung_diagnosis_app/core/errors/app_exceptions.dart';
import 'package:lung_diagnosis_app/core/failures/failure.dart';
import 'package:lung_diagnosis_app/core/network/network_exceptions.dart';

class ErrorMapper {
  static AppFailure map(Object error, [StackTrace? stackTrace]) {
    if (error is AppFailure) {
      return error;
    }

    if (error is AppException) {
      return _mapAppException(error);
    }

    if (error is DioException) {
      return NetworkExceptions.mapDioError(error);
    }

    if (error is FormatException) {
      return AppFailure(
        type: FailureType.parsing,
        message: error.message.isEmpty ? 'Invalid data format' : error.message,
        details: error,
      );
    }

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

    if (error is SocketException) {
      return AppFailure(
        type: FailureType.network,
        message: 'No internet connection',
        details: error,
      );
    }

    return AppFailure(
      type: FailureType.unknown,
      message: error.toString().trim().isEmpty ? 'Unknown error' : error.toString(),
      details: error,
    );
  }

  static AppFailure _mapAppException(AppException error) {
    if (error is NetworkException) {
      return AppFailure(
        type: FailureType.network,
        message: error.message,
        details: error.details,
      );
    }
    if (error is CacheException) {
      return AppFailure(
        type: FailureType.cache,
        message: error.message,
        details: error.details,
      );
    }
    if (error is ParsingException) {
      return AppFailure(
        type: FailureType.parsing,
        message: error.message,
        details: error.details,
      );
    }
    if (error is ValidationException) {
      return AppFailure(
        type: FailureType.validation,
        message: error.message,
        details: error.details,
      );
    }
    if (error is UnauthorizedException) {
      return AppFailure(
        type: FailureType.unauthorized,
        message: error.message,
        details: error.details,
      );
    }
    if (error is ForbiddenException) {
      return AppFailure(
        type: FailureType.forbidden,
        message: error.message,
        details: error.details,
      );
    }
    if (error is NotFoundException) {
      return AppFailure(
        type: FailureType.notFound,
        message: error.message,
        details: error.details,
      );
    }

    return AppFailure(
      type: FailureType.unknown,
      message: error.message,
      details: error.details,
    );
  }
}
