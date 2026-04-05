import 'package:flutter/material.dart';

class AppErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  final VoidCallback? onRetry;
  final String? retryText;

  const AppErrorBanner({
    super.key,
    required this.message,
    required this.onClose,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: scheme.errorContainer,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.error_outline, size: 20, color: scheme.onErrorContainer),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 13, height: 1.25, color: scheme.onErrorContainer, fontWeight: FontWeight.w600),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                child: Text(retryText ?? 'Retry'),
              ),
            ],
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 18),
              splashRadius: 18,
              tooltip: 'Close',
            ),
          ],
        ),
      ),
    );
  }
}
