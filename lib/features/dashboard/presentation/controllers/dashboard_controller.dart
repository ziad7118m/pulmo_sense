import 'package:lung_diagnosis_app/core/di/app_di.dart';
import 'package:lung_diagnosis_app/core/network/endpoints.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
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



  Future<double> loadOverallRisk(MedicalProfileRecord? medical) async {
    if (medical == null || medical.factors.isEmpty) {
      return 0.0;
    }

    final payload = <String, dynamic>{
      'obesity': _factor(medical, 'Obesity'),
      'coughingOfBlood': _factor(medical, 'Coughing of blood'),
      'alcoholUse': _factor(medical, 'Alcohol use'),
      'dustAllergy': _factor(medical, 'Dust allergy'),
      'passiveSmoker': _factor(medical, 'Passive smoker'),
      'balancedDiet': _factor(medical, 'Balanced diet'),
      'geneticRisk': _factor(medical, 'Genetic risk'),
      'occupationalHazards': _factor(medical, 'Occupational hazards'),
      'chestPain': _factor(medical, 'Chest pain'),
      'airPollution': _factor(medical, 'Air pollution'),
    };

    final result = await AppDI.apiClient.post<Map<String, dynamic>>(
      Endpoints.lungRiskAnalyze,
      body: payload,
      decode: (dynamic data) {
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      },
    );

    if (result is Success<Map<String, dynamic>>) {
      final map = result.value;
      final high = _asDouble(map['high'] ?? map['High']);
      if (high != null) {
        return _normalizePercent(high);
      }
    }

    return resolveOverallRisk(medical);
  }

  int _factor(MedicalProfileRecord medical, String key) {
    final raw = medical.factors[key] ?? 0;
    return raw.round().clamp(0, 10);
  }

  double _normalizePercent(double value) {
    if (value <= 1) return (value * 100).clamp(0, 100).toDouble();
    return value.clamp(0, 100).toDouble();
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double resolveOverallRisk(MedicalProfileRecord? medical) {
    final factors = medical?.factors.values.toList() ?? const <double>[];
    if (factors.isEmpty) return 0.0;
    return factors.reduce((a, b) => a + b) / factors.length;
  }
}
