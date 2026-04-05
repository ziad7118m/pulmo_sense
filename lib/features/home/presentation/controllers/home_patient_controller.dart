import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/helpers/dashboard_latest_diagnosis_resolver.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/home/presentation/models/home_patient_view_data.dart';

class HomePatientController {
  const HomePatientController();

  HomePatientViewData build({
    required DiagnosisHistoryRepository historyRepository,
    required AuthUser? currentUser,
  }) {
    return HomePatientViewData(
      patientName: _resolvePatientName(currentUser?.displayName),
      latestDiagnosis: resolveDashboardLatestDiagnosis(
        historyRepository: historyRepository,
        isDoctor: false,
      ),
    );
  }

  String _resolvePatientName(String? currentUserName) {
    final normalizedName = (currentUserName ?? '').trim();
    if (normalizedName.isEmpty) return AppStrings.patientName;
    return normalizedName;
  }
}
