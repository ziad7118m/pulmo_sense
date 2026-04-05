import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/onboarding/presentation/models/onboarding_page_item.dart';

class OnboardingVisualScene extends StatelessWidget {
  final OnboardingPageItem item;
  final int pageIndex;

  const OnboardingVisualScene({
    super.key,
    required this.item,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1.05,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final circleSize = width * 0.36;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 18,
                right: width * 0.08,
                child: _BlurBubble(
                  size: width * 0.34,
                  color: item.accentColors.first.withOpacity(isDark ? 0.28 : 0.18),
                ),
              ),
              Positioned(
                left: width * 0.02,
                bottom: width * 0.08,
                child: _BlurBubble(
                  size: width * 0.28,
                  color: item.accentColors.last.withOpacity(isDark ? 0.18 : 0.26),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.08 : 0.88),
                        Colors.white.withOpacity(isDark ? 0.02 : 0.48),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(isDark ? 0.08 : 0.55),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
                        blurRadius: 28,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: width * 0.08,
                right: width * 0.08,
                top: width * 0.10,
                child: Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.favorite_outline,
                        label: 'Guided checks',
                        value: pageIndex == 0 ? '3 tools' : pageIndex == 1 ? 'Fast flow' : '1 dashboard',
                        accent: item.accentColors[0],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.bubble_chart_outlined,
                        label: 'Status',
                        value: pageIndex == 0 ? 'Clear' : pageIndex == 1 ? 'Live' : 'Tracked',
                        accent: item.accentColors[1],
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: item.accentColors.take(2).toList(),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.accentColors[1].withOpacity(isDark ? 0.42 : 0.24),
                        blurRadius: 32,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(isDark ? 0.12 : 0.18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.24),
                      ),
                    ),
                    child: Icon(
                      item.heroIcon,
                      size: circleSize * 0.42,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: width * 0.08,
                bottom: width * 0.15,
                child: _FloatingInfoCard(
                  title: pageIndex == 0
                      ? 'Audio + X-ray'
                      : pageIndex == 1
                          ? 'Smooth capture'
                          : 'Recent insights',
                  subtitle: pageIndex == 0
                      ? 'Bring related signals together.'
                      : pageIndex == 1
                          ? 'Preview before you continue.'
                          : 'Follow reports with less effort.',
                  accent: item.accentColors[1],
                  icon: pageIndex == 0
                      ? Icons.wifi_tethering_rounded
                      : pageIndex == 1
                          ? Icons.multitrack_audio_rounded
                          : Icons.analytics_outlined,
                ),
              ),
              Positioned(
                right: width * 0.06,
                bottom: width * 0.26,
                child: _BadgeColumn(item: item),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(isDark ? 0.06 : 0.64),
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.06 : 0.72)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(isDark ? 0.22 : 0.12),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;

  const _FloatingInfoCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface.withOpacity(isDark ? 0.94 : 0.92),
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.06 : 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.16 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(isDark ? 0.24 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _BadgeColumn extends StatelessWidget {
  final OnboardingPageItem item;

  const _BadgeColumn({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: item.badges
          .asMap()
          .entries
          .map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: item.accentColors[entry.key % item.accentColors.length]
                    .withOpacity(isDark ? 0.18 : 0.12),
                border: Border.all(
                  color: item.accentColors[entry.key % item.accentColors.length]
                      .withOpacity(isDark ? 0.35 : 0.22),
                ),
              ),
              child: Text(
                entry.value,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BlurBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurBubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
