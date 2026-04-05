import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/risk_dashboard_donut_summary.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/risk_dashboard_pill.dart';

class RiskDashboardBody extends StatelessWidget {
  final double percentage;
  final String label;
  final String title;
  final String description;
  final String pillText;
  final Color accentColor;
  final Color healthColor;

  const RiskDashboardBody({
    super.key,
    required this.percentage,
    required this.label,
    required this.title,
    required this.description,
    required this.pillText,
    required this.accentColor,
    required this.healthColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.65)),
      ),
      child: Row(
        children: [
          RiskDashboardDonutSummary(
            percentage: percentage,
            label: label,
            accentColor: accentColor,
            healthColor: healthColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                RiskDashboardPill(text: pillText, color: accentColor),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
