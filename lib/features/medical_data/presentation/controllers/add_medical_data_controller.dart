import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/add_medical_data_view_data.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_account_option.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_mode.dart';

class AddMedicalDataController {
  const AddMedicalDataController();

  static const List<String> factorTitles = [
    'Obesity',
    'Coughing of blood',
    'Alcohol use',
    'Dust allergy',
    'Balanced diet',
    'Passive smoker',
    'Genetic risk',
    'Occupational hazards',
    'Chest pain',
    'Air pollution',
  ];

  static const String noDiseasesOption = 'No diseases';

  static const List<String> diseaseTitles = [
    'Diabetes',
    'Surgical History',
    'Heart Disease',
    'Asthma',
    'Kidney Problems',
    'Hypertension',
    'Liver Problems',
    'Food Allergy',
    'Drug Allergy',
    'Other Allergies',
    'Previous Medical Conditions',
  ];

  Map<String, double> createInitialFactors() => {
        for (final factor in factorTitles) factor: 0,
      };

  MedicalTargetAccountOption toTargetOption(AuthUser user) {
    return MedicalTargetAccountOption(
      id: user.id,
      name: user.displayName,
      email: user.email,
      role: user.role,
    );
  }

  List<MedicalTargetAccountOption> toTargetOptions(List<AuthUser> users) {
    return users.map(toTargetOption).toList(growable: false);
  }

  AuthUser? resolveOwner({
    required AuthUser currentDoctor,
    required MedicalTargetMode mode,
    required AuthUser? selectedTarget,
  }) {
    return currentDoctor;
  }

  void resetForm({
    required Map<String, double> factors,
    required Set<String> selectedDiseases,
  }) {
    for (final key in factors.keys) {
      factors[key] = 0;
    }
    selectedDiseases.clear();
  }

  void applyProfile({
    required Map<String, double> factors,
    required Set<String> selectedDiseases,
    required MedicalProfileRecord? existing,
  }) {
    for (final key in factors.keys) {
      factors[key] = existing?.factors[key] ?? 0;
    }
    selectedDiseases.clear();
  }

  List<AuthUser> filterSelectableUsers({
    required List<AuthUser> users,
    required String? currentUserId,
  }) {
    return users.where((user) => user.id != currentUserId).toList(growable: false);
  }

  void toggleDisease(Set<String> selectedDiseases, String disease) {
    final isNoneOption = disease == noDiseasesOption;
    final isSelected = selectedDiseases.contains(disease);

    if (isNoneOption) {
      if (isSelected) {
        selectedDiseases.remove(noDiseasesOption);
      } else {
        selectedDiseases
          ..clear()
          ..add(noDiseasesOption);
      }
      return;
    }

    selectedDiseases.remove(noDiseasesOption);
    if (isSelected) {
      selectedDiseases.remove(disease);
    } else {
      selectedDiseases.add(disease);
    }
  }

  String saveLabel(MedicalTargetMode mode) {
    return 'Analyze and save';
  }

  AddMedicalDataViewData buildViewData({
    required AuthUser? currentDoctor,
    required MedicalTargetMode mode,
    required AuthUser? selectedTarget,
    required bool isSaving,
    required bool isLoadingTargets,
    required String? targetLoadError,
  }) {
    return AddMedicalDataViewData(
      isDoctorEditor: currentDoctor != null,
      isSaving: isSaving,
      mode: MedicalTargetMode.me,
      currentDoctor: currentDoctor == null ? null : toTargetOption(currentDoctor),
      selectedTarget: null,
      saveLabel: saveLabel(MedicalTargetMode.me),
      needsTargetSelection: false,
      isLoadingTargets: false,
      targetLoadError: targetLoadError,
    );
  }

  String? validate({
    required AuthUser? currentDoctor,
    required AuthUser? owner,
    required MedicalTargetMode mode,
    required Set<String> selectedDiseases,
  }) {
    if (currentDoctor == null) return 'Session expired. Please log in again.';
    if (owner == null) return 'Your account is not ready yet. Please log in again.';
    return null;
  }

  MedicalProfileRecord buildProfile({
    required AuthUser owner,
    required AuthUser doctor,
    required Map<String, double> factors,
    required Set<String> selectedDiseases,
  }) {
    return MedicalProfileRecord(
      ownerId: owner.id,
      ownerRole: owner.role,
      factors: Map<String, double>.from(factors),
      diseases: const <String>[],
      createdByDoctorId: owner.id,
      createdByDoctorName: owner.displayName,
      updatedAt: DateTime.now(),
    );
  }

  String emptyAccountsMessage(MedicalTargetMode mode) {
    return 'No accounts found.';
  }
}
