import 'package:lung_diagnosis_app/features/dashboard/presentation/models/dashboard_latest_diagnosis.dart';

class HomePatientViewData {
  final String patientName;
  final DashboardLatestDiagnosis latestDiagnosis;

  const HomePatientViewData({
    required this.patientName,
    required this.latestDiagnosis,
  });
}
