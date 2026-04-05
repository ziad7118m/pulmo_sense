import 'package:flutter/material.dart';

class RoleOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final bool isDark;
  final VoidCallback onTap;

  const RoleOptionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: scheme.surface.withOpacity(isDark ? 0.18 : 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
          boxShadow: isDark
              ? const []
              : const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(isDark ? 0.4 : 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 28, color: scheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant.withOpacity(0.9),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
