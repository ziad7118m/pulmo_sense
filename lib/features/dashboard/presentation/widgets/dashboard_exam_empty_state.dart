import 'package:flutter/material.dart';

class DashboardExamEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onStartExam;

  const DashboardExamEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onStartExam,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasAction = ctaLabel != null && onStartExam != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          style: TextStyle(color: scheme.onSurfaceVariant, height: 1.3),
        ),
        if (hasAction) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartExam,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded),
                  const SizedBox(width: 8),
                  Text(ctaLabel!),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
