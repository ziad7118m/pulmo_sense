import 'package:lung_diagnosis_app/features/dashboard/presentation/models/dashboard_latest_diagnosis.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/models/user_info_data.dart';

class DashboardScreenViewData {
  final String? ownerId;
  final bool ownerIsDoctor;
  final bool isReadOnly;
  final UserInfoData userData;
  final DashboardLatestDiagnosis latestDiagnosis;

  const DashboardScreenViewData({
    required this.ownerId,
    required this.ownerIsDoctor,
    required this.isReadOnly,
    required this.userData,
    required this.latestDiagnosis,
  });
}
