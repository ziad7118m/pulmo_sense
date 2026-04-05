import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/donut_chart.dart';

class MedicalFactorDonut extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;

  const MedicalFactorDonut({
    super.key,
    required this.percentage,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        DonutChart(
          percentage: percentage,
          size: size,
          strokeWidth: strokeWidth,
          backgroundColor: scheme.surfaceVariant.withOpacity(0.75),
          showPercentageText: false,
        ),
        Container(
          width: size * 0.64,
          height: size * 0.64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.surface,
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.55)),
          ),
          child: Center(
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
