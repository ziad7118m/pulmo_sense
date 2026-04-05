import 'package:flutter/material.dart';

class MedicalFactorRiskMeta {
  final String label;
  final String hint;
  final Color color;
  final IconData icon;

  const MedicalFactorRiskMeta({
    required this.label,
    required this.hint,
    required this.color,
    required this.icon,
  });

  static MedicalFactorRiskMeta fromPercentage(double percentage) {
    if (percentage >= 70) {
      return MedicalFactorRiskMeta(
        label: 'High',
        hint: 'Needs attention',
        color: Colors.red.shade700,
        icon: Icons.warning_amber_rounded,
      );
    }

    if (percentage >= 35) {
      return const MedicalFactorRiskMeta(
        label: 'Medium',
        hint: 'Monitor it',
        color: Colors.orange,
        icon: Icons.insights,
      );
    }

    return const MedicalFactorRiskMeta(
      label: 'Low',
      hint: 'Looks stable',
      color: Colors.green,
      icon: Icons.check_circle_rounded,
    );
  }
}
