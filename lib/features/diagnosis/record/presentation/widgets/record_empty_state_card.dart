import 'package:flutter/material.dart';

class RecordEmptyStateCard extends StatelessWidget {
  const RecordEmptyStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.onSurfaceVariant.withOpacity(0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.mic_rounded, color: scheme.primary, size: 42),
            const SizedBox(height: 10),
            Text(
              'No recording yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the mic button to start recording (max 15 seconds), then analyze.',
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
