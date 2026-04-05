import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/recipient_type.dart';

class DiagnosisUploadRequest {
  final DiagnosisKind kind;
  final String filePath;
  final RecipientType recipientType;
  final String? targetPatientId;

  const DiagnosisUploadRequest({
    required this.kind,
    required this.filePath,
    this.recipientType = RecipientType.self,
    this.targetPatientId,
  });
}
