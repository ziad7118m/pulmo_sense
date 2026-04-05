import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/usecase/usecase.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/repositories/diagnosis_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/value_objects/diagnosis_upload_request.dart';

class AnalyzeRecordUseCase extends UseCase<DiagnosisResult, DiagnosisUploadRequest> {
  final DiagnosisRepository _repo;

  AnalyzeRecordUseCase(this._repo);

  @override
  Future<Result<DiagnosisResult>> call(DiagnosisUploadRequest request) {
    return _repo.analyzeRecord(request);
  }
}
