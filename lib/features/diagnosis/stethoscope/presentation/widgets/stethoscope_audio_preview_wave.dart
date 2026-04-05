import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/recording_wave.dart';

class StethoscopeAudioPreviewWave extends StatelessWidget {
  final bool showWave;
  final bool isUploaded;
  final List<double> samples;

  const StethoscopeAudioPreviewWave({
    super.key,
    required this.showWave,
    required this.isUploaded,
    required this.samples,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final waveTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(secondary: theme.colorScheme.primary),
    );

    return SizedBox(
      height: 92,
      width: double.infinity,
      child: Theme(
        data: waveTheme,
        child: showWave
            ? RecordingWave(
                isRecording: false,
                level: 0,
                samples: samples,
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color:
                      theme.colorScheme.surfaceVariant.withOpacity(0.22),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.graphic_eq_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isUploaded
                            ? 'Waveform preview is unavailable for uploaded audio files.'
                            : 'Waveform preview is not available for this clip yet.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
