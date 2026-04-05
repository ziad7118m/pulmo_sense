import 'package:dio/dio.dart';
import 'package:lung_diagnosis_app/core/config/app_config.dart';
import 'package:lung_diagnosis_app/core/errors/error_mapper.dart';
import 'package:lung_diagnosis_app/core/log/app_logger.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  final Dio _dio;

  ApiClient._(this._dio);

  factory ApiClient({
    required AppConfig config,
    TokenProvider? tokenProvider,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    if (config.isDev) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            AppLogger.d('HTTP ${options.method} ${options.uri}', data: {
              'headers': options.headers,
              'query': options.queryParameters,
            });
            handler.next(options);
          },
          onResponse: (response, handler) {
            AppLogger.d(
              'HTTP ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
              data: response.data,
            );
            handler.next(response);
          },
          onError: (e, handler) {
            AppLogger.e(
              'HTTP ERROR ${e.requestOptions.method} ${e.requestOptions.uri}',
              error: e,
              data: e.response?.data,
            );
            handler.next(e);
          },
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (tokenProvider != null) {
            final token = await tokenProvider();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
      ),
    );

    return ApiClient._(dio);
  }

  T _castOrDecode<T>(dynamic data, T Function(dynamic data)? decode) {
    if (decode != null) return decode(data);
    return data as T;
  }

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic data)? decode,
  }) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return Success<T>(_castOrDecode(res.data, decode));
    } catch (e, st) {
      AppLogger.e('GET failed: $path', error: e, stack: st);
      return FailureResult<T>(ErrorMapper.map(e, st));
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    T Function(dynamic data)? decode,
  }) async {
    try {
      final res = await _dio.post(path, data: body, queryParameters: query);
      return Success<T>(_castOrDecode(res.data, decode));
    } catch (e, st) {
      AppLogger.e('POST failed: $path', error: e, stack: st);
      return FailureResult<T>(ErrorMapper.map(e, st));
    }
  }

  Future<Result<T>> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    T Function(dynamic data)? decode,
  }) async {
    try {
      final res = await _dio.put(path, data: body, queryParameters: query);
      return Success<T>(_castOrDecode(res.data, decode));
    } catch (e, st) {
      AppLogger.e('PUT failed: $path', error: e, stack: st);
      return FailureResult<T>(ErrorMapper.map(e, st));
    }
  }

  Future<Result<T>> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    T Function(dynamic data)? decode,
  }) async {
    try {
      final res = await _dio.delete(path, data: body, queryParameters: query);
      return Success<T>(_castOrDecode(res.data, decode));
    } catch (e, st) {
      AppLogger.e('DELETE failed: $path', error: e, stack: st);
      return FailureResult<T>(ErrorMapper.map(e, st));
    }
  }

  Future<Result<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? query,
    T Function(dynamic data)? decode,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final res = await _dio.post(
        path,
        data: formData,
        queryParameters: query,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return Success<T>(_castOrDecode(res.data, decode));
    } catch (e, st) {
      AppLogger.e('POST multipart failed: $path', error: e, stack: st);
      return FailureResult<T>(ErrorMapper.map(e, st));
    }
  }

  Dio get raw => _dio;
}
