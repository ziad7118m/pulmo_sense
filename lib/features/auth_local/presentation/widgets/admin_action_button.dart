import 'package:flutter/material.dart';

class AdminActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger;
  final bool isFilled;

  const AdminActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foregroundColor = isDanger
        ? const Color(0xFFC62828)
        : isFilled
            ? Colors.white
            : scheme.primary;
    final backgroundColor = isDanger
        ? const Color(0xFFFFEBEE)
        : isFilled
            ? scheme.primary
            : scheme.primaryContainer.withOpacity(0.75);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: foregroundColor.withOpacity(isFilled ? 0.0 : 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: foregroundColor),
            const SizedBox(width: 7),
            Text(
              text,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
