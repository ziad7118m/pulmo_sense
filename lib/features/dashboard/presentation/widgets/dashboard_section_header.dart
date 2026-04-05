import 'package:flutter/material.dart';

class DashboardSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingLabel;

  const DashboardSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withOpacity(0.72),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (trailingLabel != null) ...[
          const SizedBox(width: 12),
          Text(
            trailingLabel!,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
