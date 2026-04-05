import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/button.dart';

class ArticlePostSuccessCard extends StatelessWidget {
  final VoidCallback onViewMyArticles;

  const ArticlePostSuccessCard({
    super.key,
    required this.onViewMyArticles,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      scheme.surface,
                      scheme.surfaceVariant.withOpacity(0.82),
                    ]
                  : const [
                      Color(0xFFF3F8FF),
                      Color(0xFFE8F2FF),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? scheme.outlineVariant.withOpacity(0.78)
                  : const Color(0xFFD4E5FF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary.withOpacity(0.18),
                      scheme.secondary.withOpacity(0.14),
                    ],
                  ),
                  border: Border.all(color: scheme.primary.withOpacity(0.16)),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: scheme.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.articleAlertTitle,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.articleAlertText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              CustomButton(
                text: AppStrings.articleAlertBtnText,
                height: 46,
                onPressed: onViewMyArticles,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
