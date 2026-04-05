import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/widgets/recording_wave.dart';

class RecordPreviewSection extends StatelessWidget {
  final bool isRecording;
  final bool isPlaying;
  final int recordingSeconds;
  final int maxSeconds;
  final double level;
  final List<double> waveSamples;
  final Duration position;
  final Duration duration;
  final VoidCallback onTogglePlay;
  final ValueChanged<double>? onSeek;
  final String Function(int seconds) formatDuration;
  final String Function(Duration duration) formatPlaybackDuration;

  const RecordPreviewSection({
    super.key,
    required this.isRecording,
    required this.isPlaying,
    required this.recordingSeconds,
    required this.maxSeconds,
    required this.level,
    required this.waveSamples,
    required this.position,
    required this.duration,
    required this.onTogglePlay,
    required this.onSeek,
    required this.formatDuration,
    required this.formatPlaybackDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final waveTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        secondary: scheme.primary,
      ),
    );
    final hasPreview = !isRecording && waveSamples.isNotEmpty;
    final sliderMax = (duration.inMilliseconds == 0 ? 1 : duration.inMilliseconds)
        .toDouble();
    final sliderValue = position.inMilliseconds.toDouble().clamp(0, sliderMax);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: scheme.surfaceVariant.withOpacity(isRecording ? 0.18 : 0.28),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.primary.withOpacity(isRecording ? 0.24 : 0.12),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 84,
                width: double.infinity,
                child: Theme(
                  data: waveTheme,
                  child: RecordingWave(
                    isRecording: isRecording,
                    level: level,
                    samples: hasPreview ? waveSamples : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRecording
                        ? formatDuration(recordingSeconds)
                        : formatPlaybackDuration(position),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isRecording
                        ? formatDuration(maxSeconds)
                        : formatPlaybackDuration(duration),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (hasPreview) ...[
                const SizedBox(height: 10),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: scheme.primary,
                    inactiveTrackColor: const Color(0xFFB8BEC8),
                    disabledInactiveTrackColor: const Color(0xFFD4D8DE),
                    thumbColor: scheme.primary,
                    overlayColor: scheme.primary.withOpacity(0.12),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: sliderValue.toDouble(),
                    min: 0,
                    max: sliderMax,
                    onChanged: duration == Duration.zero ? null : onSeek,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: onTogglePlay,
                    icon: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      isPlaying ? 'Pause preview' : 'Play preview',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.verified_rounded, color: scheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Ready to send',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
