import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';

class MedicalDataEmptyState extends StatelessWidget {
  final bool isDoctor;
  final VoidCallback? onAddMedicalData;

  const MedicalDataEmptyState({
    super.key,
    required this.isDoctor,
    this.onAddMedicalData,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: EmptyStateCard(
            icon: isDoctor
                ? Icons.monitor_heart_rounded
                : Icons.local_hospital_outlined,
            title: isDoctor
                ? 'No medical profile for your account yet'
                : 'No medical data available yet',
            message: isDoctor
                ? 'Add your personal medical factors once. They will automatically appear in your dashboard and medical data page.'
                : 'Your doctor needs to add your medical data before it can be shown here.',
            actionText: isDoctor ? AppStrings.addMedical : null,
            onAction: isDoctor ? onAddMedicalData : null,
          ),
        ),
      ),
    );
  }
}
