import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/diagnosis_success_card.dart';

class RecordSentSuccessCard extends StatelessWidget {
  final String timeLabel;
  final VoidCallback onRecordAnother;
  final VoidCallback onViewResult;

  const RecordSentSuccessCard({
    super.key,
    required this.timeLabel,
    required this.onRecordAnother,
    required this.onViewResult,
  });

  @override
  Widget build(BuildContext context) {
    return DiagnosisSuccessCard(
      icon: Icons.check_circle_rounded,
      title: 'Cough result sent successfully',
      message:
          'The cough recording has been analyzed and saved. You can review the result or start another recording right away.',
      metaItems: [
        SuccessMetaItem(icon: Icons.schedule_rounded, label: timeLabel),
        const SuccessMetaItem(
          icon: Icons.mic_external_on_rounded,
          label: 'One audio completed',
        ),
        const SuccessMetaItem(
          icon: Icons.history_rounded,
          label: 'Saved in your history',
        ),
      ],
      primaryLabel: 'Record another one',
      onPrimaryPressed: onRecordAnother,
      secondaryLabel: AppStrings.viewResult,
      onSecondaryPressed: onViewResult,
    );
  }
}
