import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double? height;
  final double? width;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: height ?? 50, // ارتفاع الزرار الافتراضي
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12), // افتراضي 12
          ),
        ),
        child: icon != null
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: scheme.onPrimary),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: scheme.onPrimary,
                fontWeight: FontWeight.w400
              ),
            ),
          ],
        )
            : Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: scheme.onPrimary,
            fontWeight: FontWeight.w400
          ),
        ),
      ),
    );
  }
}
