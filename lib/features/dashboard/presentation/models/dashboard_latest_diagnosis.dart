import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';

class DashboardLatestDiagnosis {
  final DiagnosisItem? latestRecord;
  final DiagnosisItem? latestXray;
  final DiagnosisItem? latestStethoscope;

  const DashboardLatestDiagnosis({
    this.latestRecord,
    this.latestXray,
    this.latestStethoscope,
  });

  bool get hasAny =>
      latestRecord != null || latestXray != null || latestStethoscope != null;
}
