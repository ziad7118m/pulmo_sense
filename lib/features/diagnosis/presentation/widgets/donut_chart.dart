import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_colors.dart';

/// ===============================
/// 🔹 Reusable Donut Chart Widget
/// ===============================
class DonutChart extends StatelessWidget {
  final double percentage; // 0 - 100
  final double size; // width & height
  final double strokeWidth; // سمك الشريط
  final Color backgroundColor; // لون الخلفية
  final bool showPercentageText; // لإظهار النسبة داخل الدونات

  const DonutChart({
    super.key,
    required this.percentage,
    this.size = 120,
    this.strokeWidth = 12,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.showPercentageText = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(
              progress: percentage / 100,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
            ),
          ),
          if (showPercentageText)
            Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}

/// ===============================
/// 🔹 Donut Painter
/// ===============================
class _DonutPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;

  _DonutPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    /// 🔹 Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    /// 🔹 Gradient progress
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      colors: AppColors.donutChartGradient.colors,
      transform: const GradientRotation(-pi / 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

    /// 🔹 End cap: لون مطابق لنقطة progress
    if (progress > 0) {
      final endAngle = startAngle + sweepAngle;
      final endOffset = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      );

      // حساب اللون عند نقطة progress
      final colors = AppColors.donutChartGradient.colors;
      Color endColor;
      if (colors.length == 2) {
        endColor = Color.lerp(colors[0], colors[1], progress)!;
      } else {
        final segment = 1.0 / (colors.length - 1);
        int index = (progress / segment).floor().clamp(0, colors.length - 2);
        double t = (progress - segment * index) / segment;
        endColor = Color.lerp(colors[index], colors[index + 1], t)!;
      }

      final endCapPaint = Paint()
        ..color = endColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(endOffset, strokeWidth / 2, endCapPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
