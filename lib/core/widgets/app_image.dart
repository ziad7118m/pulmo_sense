import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.borderRadius,
    this.placeholder,
    this.loadingLabel,
    this.errorLabel,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final String? loadingLabel;
  final String? errorLabel;

  bool get _isNetwork => path.startsWith('http://') || path.startsWith('https://');
  bool get _isSvg => path.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (_isSvg) {
      image = SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    } else if (_isNetwork) {
      image = Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _ImageLoadingCard(width: width, height: height);
        },
        errorBuilder: (_, __, ___) => placeholder ??
            _ImageStatusCard(
              width: width,
              height: height,
              label: errorLabel ?? 'Image unavailable',
              icon: Icons.broken_image_outlined,
            ),
      );
    } else {
      image = Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder ??
            _ImageStatusCard(
              width: width,
              height: height,
              label: errorLabel ?? 'Image unavailable',
              icon: Icons.broken_image_outlined,
            ),
      );
    }

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}

class _ImageLoadingCard extends StatelessWidget {
  const _ImageLoadingCard({
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceVariant.withOpacity(0.85),
            scheme.surface.withOpacity(0.95),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageStatusCard extends StatelessWidget {
  const _ImageStatusCard({
    required this.label,
    required this.icon,
    this.child,
    this.width,
    this.height,
  });

  final String label;
  final IconData icon;
  final Widget? child;
  final double? width;
  final double? height;

  bool get _isCompact {
    final resolvedWidth = width ?? 0;
    final resolvedHeight = height ?? 0;
    return (resolvedWidth > 0 && resolvedWidth <= 96) ||
        (resolvedHeight > 0 && resolvedHeight <= 96);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceVariant.withOpacity(0.85),
            scheme.surface.withOpacity(0.95),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _isCompact
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: child ?? Icon(icon, color: scheme.primary, size: 22),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: child ?? Icon(icon, color: scheme.primary, size: 22),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
