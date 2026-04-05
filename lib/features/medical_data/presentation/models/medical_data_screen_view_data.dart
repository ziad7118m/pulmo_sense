import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';

class MedicalDataScreenViewData {
  final bool isDoctor;
  final bool isInitialLoading;
  final bool hasProfile;
  final MedicalProfileRecord? profile;
  final String? updatedLabel;

  const MedicalDataScreenViewData({
    required this.isDoctor,
    required this.isInitialLoading,
    required this.hasProfile,
    required this.profile,
    required this.updatedLabel,
  });
}
