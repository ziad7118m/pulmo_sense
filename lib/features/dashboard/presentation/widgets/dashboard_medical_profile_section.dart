import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_medical_summary_card.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_factor_card.dart';

class DashboardMedicalProfileSection extends StatelessWidget {
  final MedicalProfileRecord? medical;
  final bool isDoctor;
  final String? updatedLabel;
  final VoidCallback? onAddMedicalData;
  final VoidCallback? onOpenMedicalData;
  final bool isReadOnly;

  const DashboardMedicalProfileSection({
    super.key,
    required this.medical,
    required this.isDoctor,
    this.onOpenMedicalData,
    this.updatedLabel,
    this.onAddMedicalData,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final factors = medical?.factors.entries.toList() ?? const <MapEntry<String, double>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          icon: Icons.stacked_bar_chart_rounded,
          title: 'Medical factors',
          subtitle: medical == null
              ? isReadOnly
                  ? 'This backend currently exposes lung risk factors for the signed-in account only.'
                  : 'Your dashboard will show the latest backend lung risk factors after your next saved analysis.'
              : 'Latest factor snapshot from your backend lung risk history.',
          trailingLabel: medical == null ? null : updatedLabel,
        ),
        const SizedBox(height: 12),
        if (medical == null)
          EmptyStateCard(
            icon: isDoctor ? Icons.add_chart_rounded : Icons.health_and_safety_outlined,
            title: isReadOnly
                ? 'No backend medical data for this patient view'
                : 'No backend medical data yet',
            message: isReadOnly
                ? 'Open the patient account directly if you need their own backend risk history. This app build does not map one user medical data onto another user.'
                : 'Run the lung risk analysis once and the dashboard will automatically use the latest saved backend values.',
            actionText: isReadOnly ? null : 'Update lung risk factors',
            onAction: isReadOnly ? null : onAddMedicalData,
          )
        else ...[
          DashboardMedicalSummaryCard(profile: medical!),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: factors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final factor = factors[index];
              return MedicalFactorCard(
                title: factor.key,
                percentage: factor.value,
              );
            },
          ),
          if (onOpenMedicalData != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onOpenMedicalData,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open full medical data'),
            ),
          ],
        ],
      ],
    );
  }
}
