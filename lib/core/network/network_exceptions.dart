import 'package:dio/dio.dart';
import 'package:lung_diagnosis_app/core/failures/failure.dart';

class NetworkExceptions {
  static AppFailure mapDioError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;

      // Timeouts
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return AppFailure(
          type: FailureType.timeout,
          message: 'Request timed out',
          statusCode: status,
          details: error,
        );
      }

      // Cancelled
      if (error.type == DioExceptionType.cancel) {
        return AppFailure(
          type: FailureType.network,
          message: 'Request cancelled',
          statusCode: status,
          details: error,
        );
      }

      // Connection error / no internet
      if (error.type == DioExceptionType.connectionError) {
        return AppFailure(
          type: FailureType.network,
          message: 'No internet connection',
          statusCode: status,
          details: error,
        );
      }

      // Bad response
      if (error.type == DioExceptionType.badResponse) {
        final code = status ?? -1;

        if (code == 401) {
          return AppFailure(
            type: FailureType.unauthorized,
            message: 'Unauthorized',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code == 403) {
          return AppFailure(
            type: FailureType.forbidden,
            message: 'Forbidden',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code == 404) {
          return AppFailure(
            type: FailureType.notFound,
            message: 'Not found',
            statusCode: code,
            details: error.response?.data,
          );
        }

        if (code >= 500) {
          return AppFailure(
            type: FailureType.server,
            message: 'Server error',
            statusCode: code,
            details: error.response?.data,
          );
        }

        return AppFailure(
          type: FailureType.server,
          message: 'Request failed',
          statusCode: code,
          details: error.response?.data,
        );
      }

      // Unknown Dio exception
      return AppFailure(
        type: FailureType.unknown,
        message: 'Network error',
        statusCode: status,
        details: error,
      );
    }

    // Non-dio errors
    return AppFailure(
      type: FailureType.unknown,
      message: 'Unknown error',
      details: error,
    );
  }
}
