import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIconCircle extends StatelessWidget {
  final String svgPath; // مسار الصورة
  final VoidCallback onTap;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  const SvgIconCircle({
    super.key,
    required this.svgPath,
    required this.onTap,
    this.backgroundColor = const Color.fromRGBO(105, 105, 105, 0.7), // اسود شفاف 70%
    this.size = 40,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor, // لون الخلفية أسود شفاف 70%
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          svgPath,
          width: iconSize,
          height: iconSize,
          color: Colors.white, // لون الـ SVG أبيض
        ),
      ),
    );
  }
}
