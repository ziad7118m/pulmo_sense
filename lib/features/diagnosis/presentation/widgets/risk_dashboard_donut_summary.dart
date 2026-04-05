import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/risk_dashboard_donut.dart';

class RiskDashboardDonutSummary extends StatelessWidget {
  final double percentage;
  final String label;
  final Color accentColor;
  final Color healthColor;

  const RiskDashboardDonutSummary({
    super.key,
    required this.percentage,
    required this.label,
    required this.accentColor,
    required this.healthColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        RiskDashboardDonut(
          percentage: percentage,
          size: 112,
          strokeWidth: 12,
          riskColor: Colors.red,
          healthColor: healthColor,
        ),
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.surface,
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.7),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
