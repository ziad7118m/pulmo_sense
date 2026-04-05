import 'package:flutter/material.dart';
import 'responsive.dart';

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    final t = Responsive.type(context);

    if (t == ScreenType.desktop && desktop != null) return desktop!;
    if (t == ScreenType.tablet && tablet != null) return tablet!;
    return mobile;
  }
}
