import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_factor_risk_meta.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_risk_badge.dart';

class MedicalFactorProgressSection extends StatelessWidget {
  final String title;
  final double percentage;
  final MedicalFactorRiskMeta meta;

  const MedicalFactorProgressSection({
    super.key,
    required this.title,
    required this.percentage,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            MedicalRiskBadge(meta: meta),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          meta.hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percentage / 100.0,
            minHeight: 8,
            backgroundColor: scheme.surfaceVariant.withOpacity(0.75),
            valueColor: AlwaysStoppedAnimation<Color>(meta.color),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: scheme.onSurfaceVariant.withOpacity(0.85),
            ),
            const SizedBox(width: 6),
            Text(
              'Based on latest inputs',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
