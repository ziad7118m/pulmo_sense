import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_media.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/recipient_type.dart';

class DiagnosisExam {
  final String id;
  final DiagnosisKind kind;
  final String ownerUserId;
  final String requestedByUserId;
  final RecipientType recipientType;
  final String? targetPatientId;
  final DiagnosisMedia media;
  final DiagnosisResult result;
  final DateTime createdAt;

  const DiagnosisExam({
    required this.id,
    required this.kind,
    required this.ownerUserId,
    required this.requestedByUserId,
    required this.recipientType,
    required this.media,
    required this.result,
    required this.createdAt,
    this.targetPatientId,
  });
}
