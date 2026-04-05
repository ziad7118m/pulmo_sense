import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/storage/app_storage.dart';
import 'package:lung_diagnosis_app/core/storage/keys.dart';
import 'package:lung_diagnosis_app/features/onboarding/presentation/data/onboarding_items.dart';
import 'package:lung_diagnosis_app/features/onboarding/presentation/widgets/onboarding_page_view_item.dart';
import 'package:lung_diagnosis_app/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboardingAndGoStart() async {
    await AppStorage.setBool(StorageKeys.hasSeenOnboarding, true);
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.authGate,
      (_) => false,
    );
  }

  Future<void> _handleNextPressed() async {
    if (_currentPage == onboardingItems.length - 1) {
      await _finishOnboardingAndGoStart();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF071226), Color(0xFF102447), Color(0xFF0B1832)]
                : const [Color(0xFFF7FBFF), Color(0xFFE7F1FF), Color(0xFFD4E8FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: _BackgroundGlow(
                size: 280,
                color: scheme.primary.withOpacity(isDark ? 0.18 : 0.14),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -70,
              child: _BackgroundGlow(
                size: 220,
                color: scheme.tertiary.withOpacity(isDark ? 0.16 : 0.12),
              ),
            ),
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: onboardingItems.length,
              itemBuilder: (context, index) {
                return OnboardingPageViewItem(
                  item: onboardingItems[index],
                  totalCount: onboardingItems.length,
                  currentIndex: _currentPage,
                  pageIndex: index,
                );
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withOpacity(isDark ? 0.08 : 0.72),
                        border: Border.all(
                          color: Colors.white.withOpacity(isDark ? 0.08 : 0.8),
                        ),
                      ),
                      child: Text(
                        '0${_currentPage + 1} / 0${onboardingItems.length}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onBackground,
                            ),
                      ),
                    ),
                    const Spacer(),
                    if (_currentPage < onboardingItems.length - 1)
                      TextButton(
                        onPressed: _finishOnboardingAndGoStart,
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        child: Text(
                          AppStrings.skip,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Theme.of(context).colorScheme.surface.withOpacity(isDark ? 0.92 : 0.94),
                      border: Border.all(
                        color: Colors.white.withOpacity(isDark ? 0.06 : 0.72),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.18 : 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == onboardingItems.length - 1
                                    ? 'Ready to begin?'
                                    : 'Swipe or continue',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentPage == onboardingItems.length - 1
                                    ? 'Open the app and continue with the role that fits you.'
                                    : 'Each step introduces one core part of the experience.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _handleNextPressed,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage == onboardingItems.length - 1
                                      ? AppStrings.getStarted
                                      : AppStrings.next,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
