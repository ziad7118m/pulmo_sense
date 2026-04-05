import 'package:flutter/material.dart';

enum AppTopMessageType { success, error }

class AppTopMessage {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required String message,
    required AppTopMessageType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (message.trim().isEmpty) return;

    hide();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final isSuccess = type == AppTopMessageType.success;
    final scheme = Theme.of(context).colorScheme;
    final bg = isSuccess ? scheme.primaryContainer : scheme.errorContainer;
    final fg = isSuccess ? scheme.primary : scheme.error;
    final icon = isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded;

    _entry = OverlayEntry(
      builder: (entryCtx) {
        final media = MediaQuery.maybeOf(entryCtx);
        final topInset = media?.padding.top ?? MediaQueryData.fromView(View.of(entryCtx)).padding.top;

        return Positioned(
          top: topInset + 12,
          left: 12,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 18, end: 0),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: 1 - (value / 18).clamp(0, 1),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: fg.withOpacity(0.22)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                      color: Colors.black.withOpacity(0.12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: fg.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: fg, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: hide,
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded, size: 18, color: fg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_entry!);
    Future.delayed(duration, hide);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: AppTopMessageType.success);
  }

  static void showSuccess(BuildContext context, String message) => success(context, message);

  static void error(BuildContext context, String message) {
    show(context, message: message, type: AppTopMessageType.error);
  }

  static void showError(BuildContext context, String message) => error(context, message);

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
