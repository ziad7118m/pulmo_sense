import 'package:lung_diagnosis_app/core/failures/failure.dart';

/// Result<T> = Success(value) OR Failure(error)
/// ده يخليك تمنع try/catch من الانتشار في UI والcontrollers.

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.value);
    if (self is FailureResult<T>) return failure(self.failure);
    throw StateError('Unhandled Result state: $self');
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class FailureResult<T> extends Result<T> {
  final AppFailure failure;
  const FailureResult(this.failure);
}