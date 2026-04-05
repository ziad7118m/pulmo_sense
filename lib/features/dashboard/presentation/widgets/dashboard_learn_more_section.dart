import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_quick_tip_card.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/about_disease_card.dart';

class DashboardLearnMoreSection extends StatelessWidget {
  final String title;
  final String description;
  final String tipMessage;
  final VoidCallback onOpenAbout;

  const DashboardLearnMoreSection({
    super.key,
    required this.title,
    required this.description,
    required this.tipMessage,
    required this.onOpenAbout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          icon: Icons.info_outline_rounded,
          title: 'Learn more',
          subtitle: 'Helpful information about lung health.',
        ),
        const SizedBox(height: 12),
        AboutDiseaseCard(
          title: title,
          description: description,
          onTap: onOpenAbout,
        ),
        const SizedBox(height: 16),
        DashboardQuickTipCard(message: tipMessage),
      ],
    );
  }
}
