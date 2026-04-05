import 'package:flutter/material.dart';

class AppSizes {
  /// Base design size (iPhone X)
  static const double _designWidth = 375;
  static const double _designHeight = 812;

  static late double screenWidth;
  static late double screenHeight;
  static late double textScale;

  /// لازم تتنادى مرة واحدة في أي شاشة
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    textScale = mediaQuery.textScaleFactor;
  }

  // =========================
  // Responsive sizes
  // =========================

  static double w(double value) =>
      (screenWidth / _designWidth) * value;

  static double h(double value) =>
      (screenHeight / _designHeight) * value;

  static double sp(double value) =>
      value * textScale;

  // =========================
  // Fixed spacing
  // =========================

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;

  // Radius
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r24 = 24;

  // Icon sizes
  static const double icon16 = 16;
  static const double icon20 = 20;
  static const double icon24 = 24;
  static const double icon32 = 32;
}
