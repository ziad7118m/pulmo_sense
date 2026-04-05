import 'dart:math';

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xff1b5fbf);
  static const Color secondary = Color(0xFF4290FF);
  static const Color navbar = Color(0xFF141B2C);
  static const Color background = Color(0xffF9F9FF);
  static const Color textSecondary = Color(0xFF77777A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color grayBackground = Color(0xFF696969);
  static const Color cardBackgroundWhite = Color(0xFFE0E0E0);
  static const Color darkBlue = Color(0xFF001A42);
  static const Color textBlack = Color(0xFF000000);
  static const Color alertBackground = Color(0xFFD8E2FF);
  static const Color inactiveSlider = Color(0xFFE3E2E6);
  static const Color white = Color(0XFFFFFFFF);
  static const Color darkGray = Color(0XFF5E5E62);
  static const Color red = Color(0XFFF63E3E);
  static const Color gray = Color(0XFFABABAF);
  static const Color onboarding1 = Color(0xFFF9F9FF);
  static const Color onboarding2 = Color(0xFFD0E4FF);

  static const LinearGradient navbarTabGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF8EC6FF),
      Color(0xFF84F5FF),
    ],
  );

  static const SweepGradient donutChartGradient = SweepGradient(
    colors: [
      Color(0xFF3B8CFF),
      Color(0xFF003C92),
    ],
    startAngle: 0,
    endAngle: 2 * pi,
    transform: GradientRotation(-pi/2),
  );





}
