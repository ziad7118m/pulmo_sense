import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/models/stethoscope_patient_lookup_mode.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/models/stethoscope_target_mode.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/doctor_patient_picker_card.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_doctor_target_card.dart';

class StethoscopeDoctorAssignmentSection extends StatelessWidget {
  final bool isDoctor;
  final StethoscopeTargetMode doctorTarget;
  final ValueChanged<StethoscopeTargetMode> onDoctorTargetChanged;
  final StethoscopePatientLookupMode patientMode;
  final TextEditingController patientController;
  final String? errorText;
  final String? resolvedName;
  final String? resolvedId;
  final String? resolvedAvatarPath;
  final ValueChanged<StethoscopePatientLookupMode> onPatientModeChanged;
  final VoidCallback onScan;
  final VoidCallback onConfirm;
  final bool isLoadingPatients;
  final String? patientLoadError;
  final VoidCallback? onRetryLoadPatients;

  const StethoscopeDoctorAssignmentSection({
    super.key,
    required this.isDoctor,
    required this.doctorTarget,
    required this.onDoctorTargetChanged,
    required this.patientMode,
    required this.patientController,
    required this.errorText,
    required this.resolvedName,
    required this.resolvedId,
    required this.resolvedAvatarPath,
    required this.onPatientModeChanged,
    required this.onScan,
    required this.onConfirm,
    this.isLoadingPatients = false,
    this.patientLoadError,
    this.onRetryLoadPatients,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDoctor) return const SizedBox.shrink();

    return Column(
      children: [
        StethoscopeDoctorTargetCard(
          value: doctorTarget,
          onChanged: onDoctorTargetChanged,
        ),
        const SizedBox(height: 12),
        if (doctorTarget.isPatient) ...[
          DoctorPatientPickerCard(
            mode: patientMode,
            controller: patientController,
            errorText: errorText,
            resolvedName: resolvedName,
            resolvedId: resolvedId,
            resolvedAvatarPath: resolvedAvatarPath,
            onModeChanged: onPatientModeChanged,
            onScan: onScan,
            onConfirm: onConfirm,
            isLoadingPatients: isLoadingPatients,
            loadErrorText: patientLoadError,
            onRetryLoad: onRetryLoadPatients,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
