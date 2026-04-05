import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/widgets/dashboard_diseases_panel.dart';
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
    final diseases = medical?.diseases ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          icon: Icons.stacked_bar_chart_rounded,
          title: 'Medical factors',
          subtitle: medical == null
              ? isReadOnly
                  ? 'This patient has no saved medical profile yet.'
                  : 'Your dashboard will show your medical profile once it is added.'
              : 'Live snapshot from your medical data.',
          trailingLabel: medical == null ? null : updatedLabel,
        ),
        const SizedBox(height: 12),
        if (medical == null)
          EmptyStateCard(
            icon: isDoctor ? Icons.add_chart_rounded : Icons.health_and_safety_outlined,
            title: isReadOnly
                ? 'No medical data found for this patient'
                : isDoctor
                    ? 'No medical data for this account yet'
                    : 'No medical data added yet',
            message: isReadOnly
                ? 'Open the patient medical data later once a doctor has saved it to this account.'
                : isDoctor
                    ? 'You can add medical data for yourself or for another doctor from the medical data section.'
                    : 'You need to visit a doctor so they can add your medical data to this account.',
            actionText: isReadOnly ? null : (isDoctor ? 'Add medical data' : null),
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
          const SizedBox(height: 18),
          DashboardSectionHeader(
            icon: Icons.medical_information_rounded,
            title: 'Diseases',
            subtitle: 'Conditions saved for this account.',
            trailingLabel: diseases.isEmpty ? 'Empty' : '${diseases.length} item${diseases.length == 1 ? '' : 's'}',
          ),
          const SizedBox(height: 12),
          if (diseases.isEmpty)
            const EmptyStateCard(
              icon: Icons.healing_outlined,
              title: 'No diseases added',
              message: 'The disease section is empty for this account right now.',
            )
          else
            DashboardDiseasesPanel(diseases: diseases),
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
