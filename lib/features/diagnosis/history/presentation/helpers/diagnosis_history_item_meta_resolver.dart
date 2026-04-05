import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class DiagnosisHistoryItemMetaResolver {
  static String? secondaryLine({
    required DiagnosisKind kind,
    required bool isDoctor,
    required DiagnosisItem item,
  }) {
    if (kind == DiagnosisKind.stethoscope &&
        !isDoctor &&
        (item.createdByDoctorId ?? '').trim().isNotEmpty) {
      return 'Doctor ID: ${item.createdByDoctorId}';
    }

    if (kind == DiagnosisKind.stethoscope &&
        isDoctor &&
        (item.targetPatientId ?? '').trim().isNotEmpty) {
      return 'Patient: ${item.targetPatientName ?? item.targetPatientId}';
    }

    return null;
  }
}
