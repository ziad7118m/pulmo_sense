import 'package:flutter/material.dart';

class DashboardDiseasesPanel extends StatelessWidget {
  final List<String> diseases;

  const DashboardDiseasesPanel({
    super.key,
    required this.diseases,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: diseases
            .map(
              (disease) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withOpacity(0.62),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      disease,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
