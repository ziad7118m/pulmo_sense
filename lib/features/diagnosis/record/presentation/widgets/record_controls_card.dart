import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/widgets/record_analyze_section.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/widgets/record_mic_button.dart';
import 'package:lung_diagnosis_app/features/diagnosis/record/presentation/widgets/record_preview_section.dart';

class RecordControlsCard extends StatelessWidget {
  final bool isRecording;
  final bool isRecorded;
  final bool canAnalyze;
  final bool isPlaying;
  final int recordingSeconds;
  final int maxSeconds;
  final double level;
  final List<double> waveSamples;
  final Duration position;
  final Duration duration;
  final VoidCallback onMicTap;
  final VoidCallback onTogglePlay;
  final VoidCallback onAnalyze;
  final ValueChanged<double>? onSeek;
  final String Function(int seconds) formatDuration;
  final String Function(Duration duration) formatPlaybackDuration;

  const RecordControlsCard({
    super.key,
    required this.isRecording,
    required this.isRecorded,
    required this.canAnalyze,
    required this.isPlaying,
    required this.recordingSeconds,
    required this.maxSeconds,
    required this.level,
    required this.waveSamples,
    required this.position,
    required this.duration,
    required this.onMicTap,
    required this.onTogglePlay,
    required this.onAnalyze,
    required this.onSeek,
    required this.formatDuration,
    required this.formatPlaybackDuration,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shouldShowPreview = isRecording || isRecorded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.onSurfaceVariant.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          if (shouldShowPreview)
            RecordPreviewSection(
              isRecording: isRecording,
              isPlaying: isPlaying,
              recordingSeconds: recordingSeconds,
              maxSeconds: maxSeconds,
              level: level,
              waveSamples: waveSamples,
              position: position,
              duration: duration,
              onTogglePlay: onTogglePlay,
              onSeek: onSeek,
              formatDuration: formatDuration,
              formatPlaybackDuration: formatPlaybackDuration,
            ),
          RecordMicButton(
            isRecording: isRecording,
            onTap: onMicTap,
          ),
          const SizedBox(height: 14),
          RecordAnalyzeSection(
            canAnalyze: canAnalyze,
            onAnalyze: onAnalyze,
          ),
        ],
      ),
    );
  }
}
