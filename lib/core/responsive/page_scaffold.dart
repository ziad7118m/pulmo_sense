import 'package:flutter/material.dart';
import 'responsive.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.child,
    this.maxWidth = 1100,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isWide = !Responsive.isMobile(context);

    // موبايل: زي ما هو
    if (!isWide) return Padding(padding: padding, child: child);

    // تابلت/ويب: نوسّط المحتوى في مساحة منظمة
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
    );
  }
}
