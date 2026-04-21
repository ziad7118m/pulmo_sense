import 'package:lung_diagnosis_app/features/diagnosis/data/dto/diagnosis_result_dto.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';

class DiagnosisMappers {
  static DiagnosisResult toDomain(DiagnosisResultDto dto) {
    return DiagnosisResult(
      riskLevel: dto.riskLevel,
      confidence: dto.confidence,
      recommendation: dto.recommendation,
      classProbabilities: dto.classProbabilities,
    );
  }
}
