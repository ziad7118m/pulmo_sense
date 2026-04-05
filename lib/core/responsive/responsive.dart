import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

enum ScreenType { mobile, tablet, desktop }

class Responsive {
  static ScreenType type(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= Breakpoints.desktop) return ScreenType.desktop;
    if (w >= Breakpoints.tablet) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  static bool isMobile(BuildContext context) => type(context) == ScreenType.mobile;
  static bool isTablet(BuildContext context) => type(context) == ScreenType.tablet;
  static bool isDesktop(BuildContext context) => type(context) == ScreenType.desktop;
}
