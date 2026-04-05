import 'package:flutter/material.dart';

class VerificationCodeHeader extends StatelessWidget {
  const VerificationCodeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'Code',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Enter the 6-digit code we send you',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
