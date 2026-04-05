import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/diagnosis/presentation/helpers/diagnosis_duration_formatter.dart';

class AudioPreviewProgressRow extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<double>? onSeek;

  const AudioPreviewProgressRow({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxMs = duration.inMilliseconds == 0 ? 1 : duration.inMilliseconds;
    final posMs = position.inMilliseconds.clamp(0, maxMs);

    return Row(
      children: [
        _TimePill(
          label: formatDiagnosisDuration(position),
          textColor: scheme.onSurface,
          backgroundColor: scheme.surfaceVariant.withOpacity(0.5),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: scheme.primary,
              inactiveTrackColor: scheme.onSurfaceVariant.withOpacity(0.24),
              thumbColor: scheme.primary,
              overlayColor: scheme.primary.withOpacity(0.10),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: posMs.toDouble(),
              min: 0,
              max: maxMs.toDouble(),
              onChanged: onSeek,
            ),
          ),
        ),
        _TimePill(
          label: formatDiagnosisDuration(duration),
          textColor: scheme.onSurfaceVariant,
          backgroundColor: scheme.surfaceVariant.withOpacity(0.5),
        ),
      ],
    );
  }
}

class _TimePill extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const _TimePill({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
