import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.iconSize = const Size(24, 24),
    this.width,
  });

  final String text;
  final VoidCallback onTap;

  /// Icon widget (SvgPicture / Image / Icon ...) أي حاجة
  final Widget? icon;

  final Color? backgroundColor;
  final Color? textColor;

  final double? fontSize;
  final FontWeight? fontWeight;

  final double? height;
  final double? borderRadius;

  final EdgeInsetsGeometry padding;
  final Size iconSize;

  /// لو عايز تحكم في العرض (مهم في rows)
  final double? width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = Container(
      width: width,
      height: height ?? 50,
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.primary,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      padding: padding,
      child: icon == null
          ? Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor ?? scheme.onPrimary,
            fontSize: fontSize ?? 16,
            fontWeight: fontWeight ?? FontWeight.w400,
          ),
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor ?? scheme.onPrimary,
                fontSize: fontSize ?? 16,
                fontWeight: fontWeight ?? FontWeight.w400,
              ),
            ),
          ),
          SizedBox(
            width: iconSize.width,
            height: iconSize.height,
            child: icon,
          ),
        ],
      ),
    );

    return GestureDetector(onTap: onTap, child: child);
  }
}
