import 'package:flutter/material.dart';

class AuthAccountPromptRow extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onTap;

  const AuthAccountPromptRow({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          promptText,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
