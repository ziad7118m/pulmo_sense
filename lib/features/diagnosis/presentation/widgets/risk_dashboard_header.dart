import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';

class RiskDashboardHeader extends StatelessWidget {
  final Color accentColor;

  const RiskDashboardHeader({
    super.key,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withOpacity(0.35)),
          ),
          child: Icon(Icons.health_and_safety_rounded, color: accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.riskTitle,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A quick estimate based on your latest data.',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RiskLegendChip(color: Colors.green, label: 'Healthy'),
                  _RiskLegendChip(color: Colors.red, label: 'Risk'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RiskLegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const _RiskLegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
