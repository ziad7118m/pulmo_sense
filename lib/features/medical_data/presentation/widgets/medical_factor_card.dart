import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_factor_risk_meta.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_factor_donut.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/widgets/medical_factor_progress_section.dart';

class MedicalFactorCard extends StatelessWidget {
  final String title;
  final double percentage;

  const MedicalFactorCard({
    super.key,
    required this.title,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = percentage.clamp(0, 100).toDouble();
    final meta = MedicalFactorRiskMeta.fromPercentage(pct);

    return LayoutBuilder(
      builder: (context, constraints) {
        final donutSize = (constraints.maxWidth * 0.24).clamp(68.0, 90.0);
        final stroke = (donutSize * 0.14).clamp(9.0, 12.0);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      scheme.surface,
                      scheme.surfaceVariant.withOpacity(0.82),
                    ]
                  : const [
                      Color(0xFFF3F8FF),
                      Color(0xFFE6F1FF),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? scheme.outlineVariant.withOpacity(0.82)
                  : const Color(0xFFD7E8FF),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.05),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MedicalFactorProgressSection(
                  title: title,
                  percentage: pct,
                  meta: meta,
                ),
              ),
              const SizedBox(width: 14),
              MedicalFactorDonut(
                percentage: pct,
                size: donutSize,
                strokeWidth: stroke,
              ),
            ],
          ),
        );
      },
    );
  }
}
