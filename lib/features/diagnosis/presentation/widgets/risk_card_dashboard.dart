import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/risk_dashboard_body.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/risk_dashboard_header.dart';

class RiskDashboardCard extends StatelessWidget {
  final double percentage;

  const RiskDashboardCard({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final double pct = percentage.clamp(0, 100).toDouble();
    final meta = _RiskMeta.fromPercentage(pct);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RiskDashboardHeader(accentColor: meta.color),
          const SizedBox(height: 14),
          RiskDashboardBody(
            percentage: pct,
            label: meta.label,
            title: meta.title,
            description: meta.description,
            pillText: meta.pillText,
            accentColor: meta.color,
            healthColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _RiskMeta {
  final String label;
  final String title;
  final String description;
  final String pillText;
  final Color color;

  const _RiskMeta({
    required this.label,
    required this.title,
    required this.description,
    required this.pillText,
    required this.color,
  });

  static _RiskMeta fromPercentage(double pct) {
    if (pct >= 70) {
      return _RiskMeta(
        label: 'High',
        title: 'High risk detected',
        pillText: 'Action recommended',
        description:
            'Consider consulting a doctor and reviewing the latest diagnosis details.',
        color: Colors.red.shade700,
      );
    }
    if (pct >= 35) {
      return const _RiskMeta(
        label: 'Medium',
        title: 'Moderate risk',
        pillText: 'Monitor closely',
        description:
            'Keep an eye on symptoms and follow the suggested tips and checkups.',
        color: Colors.orange,
      );
    }
    return const _RiskMeta(
      label: 'Low',
      title: 'Low risk',
      pillText: 'Keep it up',
      description:
          'Maintain your healthy routine and follow the tips to stay on track.',
      color: Colors.green,
    );
  }
}
