import 'package:flutter/material.dart';

class StethoscopeProgressCard extends StatelessWidget {
  final double progress;

  const StethoscopeProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: scheme.onSurfaceVariant,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
