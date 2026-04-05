import 'package:flutter/material.dart';

class AdminDashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const AdminDashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 126 || constraints.maxWidth < 138;
        final padding = compact ? 13.0 : 16.0;
        final iconSize = compact ? 38.0 : 42.0;
        final titleSize = compact ? 11.5 : 12.5;
        final valueSize = compact ? 23.0 : 28.0;
        final subtitleSize = compact ? 11.0 : 12.5;
        final topGap = compact ? 12.0 : 16.0;
        final middleGap = compact ? 6.0 : 8.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: isDark ? scheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
            boxShadow: isDark
                ? const []
                : [
                    BoxShadow(
                      color: accentColor.withOpacity(0.10),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accentColor, size: compact ? 20 : 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: titleSize,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: topGap),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: valueSize,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: middleGap),
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.18,
                    fontSize: subtitleSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
