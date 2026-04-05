import 'package:flutter/material.dart';

class UserInfoReadonlyRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String trailingLabel;

  const UserInfoReadonlyRow({
    super.key,
    required this.icon,
    required this.text,
    required this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: scheme.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.outlineVariant.withOpacity(0.6)),
            ),
            child: Text(
              trailingLabel,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
