import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/logic/stethoscope_controller.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_audio_preview_header.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/widgets/stethoscope_audio_preview_wave.dart';

class StethoscopeAudioPreviewCard extends StatelessWidget {
  final StethoscopeController controller;
  final Duration previewDuration;
  final Duration previewPosition;
  final bool isPreviewPlaying;
  final String Function(Duration duration) formatDuration;
  final Future<void> Function(double milliseconds) onSeek;
  final VoidCallback onTogglePreview;
  final Future<void> Function() onRemove;

  const StethoscopeAudioPreviewCard({
    super.key,
    required this.controller,
    required this.previewDuration,
    required this.previewPosition,
    required this.isPreviewPlaying,
    required this.formatDuration,
    required this.onSeek,
    required this.onTogglePreview,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final path = controller.selectedAudioPath;
    if (path == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sourceLabel = controller.sourceType == AudioSourceType.uploaded
        ? 'Uploaded audio'
        : 'Recorded audio';
    final maxMs =
        previewDuration.inMilliseconds == 0 ? 1 : previewDuration.inMilliseconds;
    final posMs = previewPosition.inMilliseconds.clamp(0, maxMs);
    final showWave = controller.sourceType == AudioSourceType.recorded &&
        controller.waveSamples.isNotEmpty;
    final isUploaded = controller.sourceType == AudioSourceType.uploaded;
    final statusText = controller.recipient == StethoscopeRecipient.doctor
        ? 'Ready to save'
        : 'Ready to send';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.surface,
            scheme.surfaceVariant.withOpacity(0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: StethoscopeAudioPreviewHeader(
                  sourceLabel: sourceLabel,
                  recipient: controller.recipient,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: scheme.primary.withOpacity(0.18),
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.surface.withOpacity(0.86),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: scheme.outlineVariant.withOpacity(0.58),
              ),
            ),
            child: StethoscopeAudioPreviewWave(
              showWave: showWave,
              isUploaded: isUploaded,
              samples: controller.waveSamples,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.surfaceVariant.withOpacity(0.58),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  formatDuration(previewPosition),
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: scheme.primary,
                    inactiveTrackColor:
                        scheme.onSurfaceVariant.withOpacity(0.24),
                    thumbColor: scheme.primary,
                    overlayColor: scheme.primary.withOpacity(0.12),
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: posMs.toDouble(),
                    min: 0,
                    max: maxMs.toDouble(),
                    onChanged:
                        previewDuration == Duration.zero ? null : onSeek,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.surfaceVariant.withOpacity(0.58),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  formatDuration(previewDuration),
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isPreviewPlaying
                        ? const Color(0xFFE53E3E)
                        : scheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: onTogglePreview,
                  icon: Icon(
                    isPreviewPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    isPreviewPlaying ? 'Pause preview' : 'Play preview',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.onSurface,
                  side: BorderSide(
                    color: scheme.outlineVariant.withOpacity(0.9),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  backgroundColor: scheme.surface,
                ),
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: scheme.error,
                ),
                label: const Text(
                  'Remove',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
