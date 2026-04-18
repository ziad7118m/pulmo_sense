import 'package:flutter/material.dart';

class VerificationResendRow extends StatelessWidget {
  final bool canResend;
  final int timer;
  final VoidCallback onResend;

  const VerificationResendRow({
    super.key,
    required this.canResend,
    required this.timer,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = canResend ? 'Didn\'t receive the code?' : 'You can request a new code in ${timer}s';

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        TextButton(
          onPressed: canResend ? onResend : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            canResend ? 'Resend' : 'Resend',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: canResend ? scheme.primary : scheme.outline,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
