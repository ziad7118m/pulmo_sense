import 'package:flutter/material.dart';

class AuthScreenHeader extends StatelessWidget {
  final String title;
  final String imageAsset;
  final double imageHeight;
  final Color? titleColor;

  const AuthScreenHeader({
    super.key,
    required this.title,
    required this.imageAsset,
    this.imageHeight = 150,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          imageAsset,
          height: imageHeight,
        ),
        const SizedBox(height: 30),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: titleColor ?? const Color(0xFF2277F0),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
