import 'package:lung_diagnosis_app/core/failures/failure.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';

extension ResultX<T> on Result<T> {
  T? getOrNull() => when(success: (v) => v, failure: (_) => null);

  AppFailure? failureOrNull() => when(success: (_) => null, failure: (f) => f);

  Result<R> map<R>(R Function(T value) transform) {
    return when(
      success: (v) => Success<R>(transform(v)),
      failure: (f) => FailureResult<R>(f),
    );
  }

  Result<R> flatMap<R>(Result<R> Function(T value) next) {
    return when(
      success: (v) => next(v),
      failure: (f) => FailureResult<R>(f),
    );
  }

  Result<T> onFailure(void Function(AppFailure failure) fn) {
    return when(
      success: (v) => Success<T>(v),
      failure: (f) {
        fn(f);
        return FailureResult<T>(f);
      },
    );
  }

  Result<T> onSuccess(void Function(T value) fn) {
    return when(
      success: (v) {
        fn(v);
        return Success<T>(v);
      },
      failure: (f) => FailureResult<T>(f),
    );
  }
}
