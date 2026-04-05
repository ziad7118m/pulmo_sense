import 'dart:math' as math;

import 'package:flutter/material.dart';

class LiveWavePainter extends CustomPainter {
  final List<double> bars;
  final double barWidth;
  final double spacing;
  final double phase;
  final double Function(double) totalHeightFor;
  final Color color;

  LiveWavePainter({
    required this.bars,
    required this.barWidth,
    required this.spacing,
    required this.phase,
    required this.totalHeightFor,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final step = barWidth + spacing;
    final centerY = size.height / 2;
    final maxBars = (size.width / step).floor().clamp(1, 9999);
    final visibleBars = bars.length > maxBars + 2
        ? bars.sublist(bars.length - (maxBars + 2))
        : bars;

    _drawBaseline(canvas, size, color.withOpacity(0.09), barWidth, spacing);

    double x = -phase * step;
    for (int index = 0; index < visibleBars.length; index++) {
      final value = visibleBars[index].clamp(0.0, 1.0);
      final total = totalHeightFor(value);
      final px = x + (barWidth / 2);

      if (px >= -barWidth && px <= size.width + barWidth) {
        final rect = Rect.fromCenter(
          center: Offset(px, centerY),
          width: barWidth,
          height: total,
        );
        final rrect = RRect.fromRectAndRadius(
          rect,
          Radius.circular(barWidth * 0.8),
        );

        final fillPaint = Paint()..color = color.withOpacity(0.92);
        canvas.drawRRect(rrect, fillPaint);
      }

      x += step;
      if (x > size.width + step) break;
    }
  }

  @override
  bool shouldRepaint(covariant LiveWavePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.bars.length != bars.length ||
        oldDelegate.color != color ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.spacing != spacing;
  }
}

class StaticWavePainter extends CustomPainter {
  final List<double> samples;
  final Color color;
  final double barWidth;
  final double spacing;
  final double Function(double) totalHeightFor;

  StaticWavePainter({
    required this.samples,
    required this.color,
    required this.barWidth,
    required this.spacing,
    required this.totalHeightFor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final step = barWidth + spacing;
    final centerY = size.height / 2;
    final maxBars = (size.width / step).floor().clamp(1, 9999);
    final bars = samples.isEmpty
        ? const <double>[]
        : (samples.length > maxBars
            ? samples.sublist(samples.length - maxBars)
            : samples);

    _drawBaseline(canvas, size, color.withOpacity(0.09), barWidth, spacing);

    double x = 0;
    for (int index = 0; index < bars.length; index++) {
      final value = bars[index].clamp(0.0, 1.0);
      final total = totalHeightFor(value);
      final px = x + (barWidth / 2);
      final rect = Rect.fromCenter(
        center: Offset(px, centerY),
        width: barWidth,
        height: total,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(barWidth * 0.8)),
        Paint()..color = color.withOpacity(0.88),
      );

      x += step;
      if (x > size.width + step) break;
    }
  }

  @override
  bool shouldRepaint(covariant StaticWavePainter oldDelegate) {
    return oldDelegate.samples.length != samples.length ||
        (samples.isNotEmpty &&
            oldDelegate.samples.isNotEmpty &&
            oldDelegate.samples.last != samples.last) ||
        oldDelegate.color != color ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.spacing != spacing;
  }
}

void _drawBaseline(
  Canvas canvas,
  Size size,
  Color color,
  double barWidth,
  double spacing,
) {
  final paint = Paint()..color = color;
  final step = barWidth + spacing;
  final centerY = size.height / 2;
  final pillWidth = math.max(3.5, barWidth - 0.8);
  const baselineHeight = 5.0;

  for (double x = 0; x <= size.width + step; x += step) {
    final rect = Rect.fromCenter(
      center: Offset(x + (pillWidth / 2), centerY),
      width: pillWidth,
      height: baselineHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(999)),
      paint,
    );
  }
}
