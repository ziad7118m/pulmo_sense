import 'package:lung_diagnosis_app/core/result/result.dart';

/// Base abstraction for a use-case.
///
/// - Presentation layer depends on use-cases.
/// - Use-cases depend on domain repositories.
abstract class UseCase<Out, In> {
  Future<Result<Out>> call(In params);
}

/// For use-cases without input params.
class NoParams {
  const NoParams();
}
