import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_factor_risk_meta.dart';

class MedicalRiskBadge extends StatelessWidget {
  final MedicalFactorRiskMeta meta;

  const MedicalRiskBadge({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: meta.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: meta.color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 16, color: meta.color),
          const SizedBox(width: 8),
          Text(
            meta.label,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
