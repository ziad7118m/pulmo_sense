import 'package:flutter/material.dart';

class DashboardExamResultCard extends StatelessWidget {
  final String date;
  final String diagnosis;
  final double percentage;

  const DashboardExamResultCard({
    super.key,
    required this.date,
    required this.diagnosis,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  scheme.surfaceVariant.withOpacity(0.36),
                  scheme.surfaceVariant.withOpacity(0.2),
                ]
              : const [
                  Color(0xFFF4F9FF),
                  Color(0xFFEAF3FF),
                ],
        ),
        border: Border.all(
          color: isDark
              ? scheme.outlineVariant.withOpacity(0.55)
              : const Color(0xFFD6E6FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (date.isNotEmpty)
            Text(
              date,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          if (date.isNotEmpty) const SizedBox(height: 6),
          Text(
            diagnosis.isEmpty ? 'Result available' : diagnosis,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percentage.clamp(0, 100) / 100.0,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? scheme.surface
                        : const Color(0xFFDDEBFF),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
