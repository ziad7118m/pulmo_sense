import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/value_objects/diagnosis_upload_request.dart';

abstract class DiagnosisRepository {
  Future<Result<DiagnosisResult>> analyzeXray(DiagnosisUploadRequest request);

  Future<Result<DiagnosisResult>> analyzeAudio(DiagnosisUploadRequest request);

  Future<Result<DiagnosisResult>> analyzeRecord(DiagnosisUploadRequest request);
}
