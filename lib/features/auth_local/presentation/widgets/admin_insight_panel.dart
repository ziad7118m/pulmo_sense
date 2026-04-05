import 'package:flutter/material.dart';

class AdminInsightItem {
  final String label;
  final String value;
  final IconData icon;

  const AdminInsightItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class AdminInsightPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AdminInsightItem> items;

  const AdminInsightPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? scheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.8)),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map(
            (entry) {
              final item = entry.value;
              final isLast = entry.key == items.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: scheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      item.value,
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
