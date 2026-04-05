import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/recording_wave.dart';

class StethoscopeRecordingPreviewCard extends StatelessWidget {
  final double level;
  final String elapsedLabel;
  final String maxDurationLabel;

  const StethoscopeRecordingPreviewCard({
    super.key,
    required this.level,
    required this.elapsedLabel,
    required this.maxDurationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final waveTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(secondary: scheme.primary),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recording preview',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Chest sound capture in progress',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$elapsedLabel / $maxDurationLabel',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: scheme.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 96,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.surfaceVariant.withOpacity(0.28),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: scheme.outlineVariant.withOpacity(0.6),
              ),
            ),
            child: Theme(
              data: waveTheme,
              child: RecordingWave(isRecording: true, level: level),
            ),
          ),
        ],
      ),
    );
  }
}
