import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';

class StethoscopeEmptyState extends StatelessWidget {
  const StethoscopeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateCard(
      icon: Icons.graphic_eq_rounded,
      title: 'No audio selected',
      message: 'Record your stethoscope sound or upload an audio file to analyze.',
    );
  }
}
