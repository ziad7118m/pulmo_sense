import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/diagnosis_success_card.dart';

class XraySentSuccessCard extends StatelessWidget {
  final String timeLabel;
  final VoidCallback onUploadAnother;
  final VoidCallback onViewResult;

  const XraySentSuccessCard({
    super.key,
    required this.timeLabel,
    required this.onUploadAnother,
    required this.onViewResult,
  });

  @override
  Widget build(BuildContext context) {
    return DiagnosisSuccessCard(
      icon: Icons.cloud_done_rounded,
      title: 'X-ray result sent successfully',
      message:
          'Your X-ray image has been analyzed and saved. You can review the result now or start another upload.',
      metaItems: [
        SuccessMetaItem(icon: Icons.schedule_rounded, label: timeLabel),
        const SuccessMetaItem(
          icon: Icons.image_rounded,
          label: '1 image analyzed',
        ),
        const SuccessMetaItem(
          icon: Icons.verified_rounded,
          label: 'Saved successfully',
        ),
      ],
      primaryLabel: 'Upload another image',
      onPrimaryPressed: onUploadAnother,
      secondaryLabel: AppStrings.viewResult,
      onSecondaryPressed: onViewResult,
    );
  }
}
