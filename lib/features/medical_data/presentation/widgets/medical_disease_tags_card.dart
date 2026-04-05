import 'package:flutter/material.dart';

class MedicalDiseaseTagsCard extends StatelessWidget {
  final List<String> diseases;

  const MedicalDiseaseTagsCard({super.key, required this.diseases});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.8)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: diseases
            .map(
              (disease) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  disease,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
