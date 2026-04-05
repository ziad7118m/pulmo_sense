import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_info_row.dart';

class AdminUserInfoCard extends StatelessWidget {
  final String title;
  final List<AdminInfoRow> rows;
  final IconData? icon;
  final String? subtitle;

  const AdminUserInfoCard({
    super.key,
    required this.title,
    required this.rows,
    this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? scheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.07),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: scheme.primary),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...rows.asMap().entries.map(
            (entry) {
              final row = entry.value;
              final isLast = entry.key == rows.length - 1;
              return Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: scheme.surfaceVariant.withOpacity(0.38),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 108,
                      child: Text(
                        row.label,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        row.value,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
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
