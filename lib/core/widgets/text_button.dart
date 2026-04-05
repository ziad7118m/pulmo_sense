import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? scheme.primary,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
