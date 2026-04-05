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
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final BorderRadius? borderRadius;

  /// Widget يظهر لو الصورة فشلت
  final Widget? placeholder;

  bool get _isNetwork => path.startsWith('http');
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
        errorBuilder: (_, __, ___) =>
        placeholder ?? const Icon(Icons.broken_image),
      );
    } else {
      image = Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) =>
        placeholder ?? const Icon(Icons.broken_image),
      );
    }

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
