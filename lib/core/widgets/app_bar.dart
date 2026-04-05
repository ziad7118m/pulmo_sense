import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final double elevation;
  final Color backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.elevation = 0,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    final Color effectiveBg = backgroundColor == Colors.transparent
        ? (isDark ? Colors.transparent : const Color(0xFFF3F8FF))
        : backgroundColor;
    final bool useLightForeground = !isDark &&
        effectiveBg.computeLuminance() < 0.45 &&
        effectiveBg != theme.scaffoldBackgroundColor;
    final Color effectiveFg = useLightForeground ? Colors.white : scheme.primary;

    return AppBar(
      backgroundColor: effectiveBg,
      surfaceTintColor:
          isDark ? Colors.transparent : scheme.primary.withOpacity(0.08),
      elevation: elevation,
      scrolledUnderElevation: isDark ? 0 : 1,
      shadowColor: scheme.shadow.withOpacity(0.08),
      centerTitle: true,
      automaticallyImplyLeading: showBack,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: effectiveFg,
        ),
      ),
      actions: actions,
      iconTheme: IconThemeData(color: effectiveFg),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
