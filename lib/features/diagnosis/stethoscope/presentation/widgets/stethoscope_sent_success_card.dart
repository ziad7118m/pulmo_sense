import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/diagnosis_success_card.dart';

class StethoscopeSentSuccessCard extends StatelessWidget {
  final bool isForDoctor;
  final String targetLabel;
  final String timeLabel;
  final VoidCallback onRecordAnother;
  final VoidCallback onViewResult;

  const StethoscopeSentSuccessCard({
    super.key,
    required this.isForDoctor,
    required this.targetLabel,
    required this.timeLabel,
    required this.onRecordAnother,
    required this.onViewResult,
  });

  @override
  Widget build(BuildContext context) {
    return DiagnosisSuccessCard(
      icon: Icons.check_circle_rounded,
      title: isForDoctor
          ? 'Stethoscope recording saved successfully'
          : 'Stethoscope result sent successfully',
      message: isForDoctor
          ? 'This recording is now available in your personal stethoscope history. You can review it or start another recording.'
          : 'The stethoscope recording was analyzed and delivered successfully. You can review it now or prepare another recording.',
      metaItems: [
        SuccessMetaItem(icon: Icons.schedule_rounded, label: timeLabel),
        SuccessMetaItem(icon: Icons.person_rounded, label: targetLabel),
        const SuccessMetaItem(
          icon: Icons.graphic_eq_rounded,
          label: 'Audio analysis completed',
        ),
      ],
      primaryLabel: 'Record another one',
      onPrimaryPressed: onRecordAnother,
      secondaryLabel: AppStrings.viewResult,
      onSecondaryPressed: onViewResult,
    );
  }
}
