import 'package:flutter/material.dart';

class RoleSelectionNoteCard extends StatelessWidget {
  final bool isDark;

  const RoleSelectionNoteCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(isDark ? 0.18 : 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.8)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: scheme.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You can change your role later from your account settings.',
              style: TextStyle(
                color: isDark ? scheme.onSurface : scheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
