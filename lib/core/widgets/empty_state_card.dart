import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_button.dart';

class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAction = actionText != null && onAction != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              ? scheme.outlineVariant.withOpacity(0.80)
              : const Color(0xFFD4E5FF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withOpacity(0.16),
                  scheme.secondary.withOpacity(0.14),
                ],
              ),
              border: Border.all(color: scheme.primary.withOpacity(0.18)),
            ),
            child: Icon(icon, color: scheme.primary, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurfaceVariant,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasAction) ...[
            const SizedBox(height: 18),
            AppButton(
              text: actionText!,
              onTap: onAction!,
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }
}
