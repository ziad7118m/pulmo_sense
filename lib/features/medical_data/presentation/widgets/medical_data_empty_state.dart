import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';

class MedicalDataEmptyState extends StatelessWidget {
  final bool canEdit;
  final VoidCallback? onAddMedicalData;
  final VoidCallback? onOpenHistory;

  const MedicalDataEmptyState({
    super.key,
    required this.canEdit,
    this.onAddMedicalData,
    this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: EmptyStateCard(
            icon: Icons.analytics_outlined,
            title: 'No backend lung risk data yet',
            message: canEdit
                ? 'Run the backend lung risk analysis once and the latest saved factors will appear here automatically.'
                : 'Sign in again, then run the backend lung risk analysis to populate this page.',
            actionText: canEdit ? 'Add lung risk factors' : null,
            onAction: canEdit ? onAddMedicalData : onOpenHistory,
          ),
        ),
      ),
    );
  }
}
