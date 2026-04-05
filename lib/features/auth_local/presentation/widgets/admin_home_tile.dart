import 'package:flutter/material.dart';

class AdminHomeTileData {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? countLabel;
  final Color? accentColor;

  const AdminHomeTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.countLabel,
    this.accentColor,
  });
}

class AdminHomeTile extends StatelessWidget {
  final AdminHomeTileData data;

  const AdminHomeTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = data.accentColor ?? scheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? scheme.surface : Colors.white,
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
            boxShadow: isDark
                ? const []
                : [
                    BoxShadow(
                      color: accent.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(isDark ? 0.18 : 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(data.icon, color: accent),
                    ),
                    const Spacer(),
                    if (data.countLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(isDark ? 0.16 : 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          data.countLabel!,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.18,
                    fontSize: 12.8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Open section',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
