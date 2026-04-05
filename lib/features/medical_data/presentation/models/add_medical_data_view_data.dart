import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_account_option.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_mode.dart';

class AddMedicalDataViewData {
  final bool isDoctorEditor;
  final bool isSaving;
  final MedicalTargetMode mode;
  final MedicalTargetAccountOption? currentDoctor;
  final MedicalTargetAccountOption? selectedTarget;
  final String saveLabel;
  final bool needsTargetSelection;
  final bool isLoadingTargets;
  final String? targetLoadError;

  const AddMedicalDataViewData({
    required this.isDoctorEditor,
    required this.isSaving,
    required this.mode,
    required this.currentDoctor,
    required this.selectedTarget,
    required this.saveLabel,
    required this.needsTargetSelection,
    required this.isLoadingTargets,
    required this.targetLoadError,
  });
}
