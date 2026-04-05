import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/recording_wave.dart';

class DiagnosisDetailsWaveCard extends StatelessWidget {
  final bool hasAudio;
  final DiagnosisItem item;

  const DiagnosisDetailsWaveCard({
    super.key,
    required this.hasAudio,
    required this.item,
  });

  bool get _hasSavedWave => item.waveSamples != null && item.waveSamples!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!hasAudio) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    if (item.audioSourceType == AudioSourceType.recorded && _hasSavedWave) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.surface,
                scheme.surfaceVariant.withOpacity(0.24),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.72),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.graphic_eq_rounded, color: scheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Audio waveform',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w900,
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
                  color: scheme.surface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.54),
                  ),
                ),
                child: SizedBox(
                  height: 90,
                  child: RecordingWave(
                    isRecording: false,
                    level: 0,
                    samples: item.waveSamples,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (item.audioSourceType == AudioSourceType.uploaded) {
      return _messageCard(
        context,
        message: 'Waveform preview is not available for uploaded audio files.',
      );
    }

    return _messageCard(
      context,
      message: 'Waveform data is not available for this recording.',
    );
  }

  Widget _messageCard(BuildContext context, {required String message}) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: scheme.outlineVariant.withOpacity(0.68),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.graphic_eq_rounded,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
