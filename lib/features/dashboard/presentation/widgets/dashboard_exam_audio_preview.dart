import 'package:flutter/material.dart';

class DashboardExamAudioPreview extends StatelessWidget {
  final List samples;
  final Color color;
  final Color faintColor;

  const DashboardExamAudioPreview({
    super.key,
    required this.samples,
    required this.color,
    required this.faintColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasSamples = samples.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.graphic_eq_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Audio preview',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 92,
            child: hasSamples
                ? _DashboardExamWaveBars(
                    samples: samples,
                    color: color,
                  )
                : Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.graphic_eq_rounded,
                            color: scheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          'Waveform preview not available',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DashboardExamWaveBars extends StatelessWidget {
  final List samples;
  final Color color;

  const _DashboardExamWaveBars({
    required this.samples,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bars = _downSample(samples);

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            bars.length,
            (index) {
              final v = bars[index].clamp(0.0, 1.0);
              final double h = (48 * v) + 12;

              return Container(
                width: 4,
                height: h,
                margin: const EdgeInsets.symmetric(horizontal: 1.4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static List<double> _downSample(List raw) {
    if (raw.isEmpty) return const <double>[];
    final data = raw
        .map((e) => (e is num ? e.toDouble() : 0.0))
        .map((e) => e.isFinite ? e.abs() : 0.0)
        .toList();

    final target = data.length < 18
        ? 18
        : data.length < 36
            ? 24
            : data.length < 70
                ? 30
                : 36;

    if (data.length <= target) {
      return data.map((e) => e.clamp(0.0, 1.0)).toList();
    }

    final step = data.length / target;
    final out = <double>[];
    for (int i = 0; i < target; i++) {
      final start = (i * step).floor().clamp(0, data.length - 1);
      final end = (((i + 1) * step).ceil()).clamp(start + 1, data.length);
      double peak = 0;
      for (int j = start; j < end; j++) {
        if (data[j] > peak) peak = data[j];
      }
      out.add(peak.clamp(0.0, 1.0));
    }
    return out;
  }
}
