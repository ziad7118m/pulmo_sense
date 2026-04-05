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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          canResend ? 'Resend code' : 'Wait for $timer seconds.',
          style: TextStyle(
            color: canResend ? scheme.primary : Colors.grey,
          ),
        ),
        if (canResend)
          TextButton(
            onPressed: onResend,
            child: Text(
              'Resend',
              style: TextStyle(color: scheme.primary),
            ),
          ),
      ],
    );
  }
}
