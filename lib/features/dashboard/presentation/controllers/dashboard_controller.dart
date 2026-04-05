import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/helpers/dashboard_latest_diagnosis_resolver.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/helpers/dashboard_user_data_builder.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/models/dashboard_patient_view.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/models/dashboard_screen_view_data.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/repositories/medical_profile_repository.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class DashboardController {
  final DiagnosisHistoryRepository _historyRepository;
  final MedicalProfileRepository _medicalProfileRepository;

  const DashboardController({
    required DiagnosisHistoryRepository historyRepository,
    required MedicalProfileRepository medicalProfileRepository,
  }) : _historyRepository = historyRepository,
       _medicalProfileRepository = medicalProfileRepository;

  DashboardScreenViewData build({
    required AuthUser? currentUser,
    required UserProfile? currentProfile,
    required DashboardPatientView? patientView,
  }) {
    final ownerId = resolveOwnerId(
      currentUser: currentUser,
      patientView: patientView,
    );
    final ownerIsDoctor =
        patientView == null && (currentUser?.role == UserRole.doctor);

    return DashboardScreenViewData(
      ownerId: ownerId,
      ownerIsDoctor: ownerIsDoctor,
      isReadOnly: patientView != null,
      userData: DashboardUserDataBuilder.build(
        currentUser: currentUser,
        currentProfile: currentProfile,
        patientView: patientView,
      ),
      latestDiagnosis: resolveDashboardLatestDiagnosis(
        historyRepository: _historyRepository,
        isDoctor: ownerIsDoctor,
        userId: ownerId,
      ),
    );
  }

  String? resolveOwnerId({
    required AuthUser? currentUser,
    required DashboardPatientView? patientView,
  }) {
    return patientView?.userId ?? currentUser?.id;
  }

  Future<MedicalProfileRecord?> loadMedicalProfile(String? ownerId) {
    final normalizedOwnerId = (ownerId ?? '').trim();
    if (normalizedOwnerId.isEmpty) {
      return Future.value(null);
    }
    return _medicalProfileRepository.getProfile(normalizedOwnerId);
  }

  double resolveOverallRisk(MedicalProfileRecord? medical) {
    final factors = medical?.factors.values.toList() ?? const <double>[];
    if (factors.isEmpty) return 0.0;
    return factors.reduce((a, b) => a + b) / factors.length;
  }
}
