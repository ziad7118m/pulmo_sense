import 'package:flutter/material.dart';

class OnboardingPageItem {
  final String overline;
  final String title;
  final String description;
  final String supportingText;
  final IconData heroIcon;
  final List<String> badges;
  final List<Color> accentColors;

  const OnboardingPageItem({
    required this.overline,
    required this.title,
    required this.description,
    required this.supportingText,
    required this.heroIcon,
    required this.badges,
    required this.accentColors,
  });
}
