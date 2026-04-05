import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/onboarding/presentation/models/onboarding_page_item.dart';
import 'package:lung_diagnosis_app/features/onboarding/presentation/widgets/onboarding_visual_scene.dart';

class OnboardingPageViewItem extends StatelessWidget {
  final OnboardingPageItem item;
  final int totalCount;
  final int currentIndex;
  final int pageIndex;

  const OnboardingPageViewItem({
    super.key,
    required this.item,
    required this.totalCount,
    required this.currentIndex,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 190),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: scheme.primary.withOpacity(isDark ? 0.18 : 0.10),
                  border: Border.all(
                    color: scheme.primary.withOpacity(isDark ? 0.28 : 0.16),
                  ),
                ),
                child: Text(
                  item.overline,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                      color: scheme.onBackground,
                    ),
              ),
              const SizedBox(height: 14),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 28),
              OnboardingVisualScene(
                item: item,
                pageIndex: pageIndex,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white.withOpacity(isDark ? 0.06 : 0.62),
                  border: Border.all(
                    color: Colors.white.withOpacity(isDark ? 0.06 : 0.72),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.supportingText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    OnboardingPageIndicator(
                      currentIndex: currentIndex,
                      totalCount: totalCount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const OnboardingPageIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 8,
          width: currentIndex == index ? 28 : 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? scheme.primary
                : scheme.outlineVariant.withOpacity(isDark ? 0.9 : 0.8),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
