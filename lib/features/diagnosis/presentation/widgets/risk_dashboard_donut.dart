import 'package:flutter/material.dart';

class RiskDashboardDonut extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final Color riskColor;
  final Color healthColor;

  const RiskDashboardDonut({
    super.key,
    required this.percentage,
    required this.size,
    required this.strokeWidth,
    required this.riskColor,
    required this.healthColor,
  });

  @override
  Widget build(BuildContext context) {
    final pct = percentage.clamp(0, 100).toDouble();
    return SizedBox(
      height: size,
      width: size,
      child: CustomPaint(
        painter: _RiskDashboardDonutPainter(
          riskPercent: pct / 100.0,
          strokeWidth: strokeWidth,
          riskColor: riskColor,
          healthColor: healthColor,
        ),
      ),
    );
  }
}

class _RiskDashboardDonutPainter extends CustomPainter {
  final double riskPercent;
  final double strokeWidth;
  final Color riskColor;
  final Color healthColor;

  const _RiskDashboardDonutPainter({
    required this.riskPercent,
    required this.strokeWidth,
    required this.riskColor,
    required this.healthColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth / 2;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = healthColor;

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = riskColor;

    const startAngle = -1.5707963267948966;
    const full = 6.283185307179586;
    final sweepRisk = full * riskPercent.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      full,
      false,
      bg,
    );
    if (sweepRisk > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepRisk,
        false,
        fg,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RiskDashboardDonutPainter oldDelegate) {
    return oldDelegate.riskPercent != riskPercent ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.riskColor != riskColor ||
        oldDelegate.healthColor != healthColor;
  }
}
