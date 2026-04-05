import 'dart:async';

import 'package:lung_diagnosis_app/core/errors/error_mapper.dart';
import 'package:lung_diagnosis_app/core/failures/failure.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/utils/unit.dart';

/// A tiny helper to reduce boilerplate try/catch in repositories & services.
///
/// Usage:
/// ```dart
/// return ResultGuard.guard(() async {
///   final data = await datasource.fetch();
///   return mapper(data);
/// });
/// ```
class ResultGuard {
  const ResultGuard._();

  static Future<Result<T>> guard<T>(
    FutureOr<T> Function() action, {
    AppFailure Function(Object error, StackTrace st)? mapError,
  }) async {
    try {
      final v = await Future.sync(action);
      return Success<T>(v);
    } catch (e, st) {
      final failure = mapError?.call(e, st) ?? ErrorMapper.map(e, st);
      return FailureResult<T>(failure);
    }
  }

  /// Same as [guard] but for operations without a meaningful return value.
  ///
  /// Prefer returning `Result<Unit>` instead of `Result<void>` to avoid `void` generics.
  static Future<Result<Unit>> guardUnit(
    FutureOr<void> Function() action, {
    AppFailure Function(Object error, StackTrace st)? mapError,
  }) async {
    try {
      await Future.sync(action);
      return const Success<Unit>(Unit.value);
    } catch (e, st) {
      final failure = mapError?.call(e, st) ?? ErrorMapper.map(e, st);
      return FailureResult<Unit>(failure);
    }
  }
}
