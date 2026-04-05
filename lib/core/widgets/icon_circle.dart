import 'package:flutter/material.dart';

class IconCircle extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const IconCircle({
    super.key,
    required this.icon,
    this.size = 20,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor ?? scheme.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? scheme.onSurface, size: size),
      ),
    );
  }
}
