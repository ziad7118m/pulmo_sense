import 'package:flutter/material.dart';

class CustomButtonRow extends StatelessWidget {
  final List<ButtonData> buttons;

  const CustomButtonRow({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(buttons.length, (index) {
        final button = buttons[index];
        return Expanded(
          child: GestureDetector(
            onTap: button.onTap,
            child: Container(
              height: button.height ?? 48,
              decoration: BoxDecoration(
                color: button.color ?? Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(button.borderRadius ?? 12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    button.text,
                    style: TextStyle(
                      color: button.textColor ?? Colors.white,
                      fontSize: button.fontSize ?? 16,
                      fontWeight: button.fontWeight ?? FontWeight.w300,
                    ),
                  ),
                  // لو فيه Widget (زي SVG) نستخدمه، لو مش موجود نستخدم الصورة العادية
                  if (button.iconWidget != null)
                    SizedBox(
                      width: button.iconWidth ?? 24,
                      height: button.iconHeight ?? 24,
                      child: button.iconWidget,
                    )
                  else if (button.iconPath != null)
                    Image.asset(
                      button.iconPath!,
                      width: button.iconWidth ?? 24,
                      height: button.iconHeight ?? 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).expand((widget) sync* {
        yield widget;
        if (widget != buttons.last) yield const SizedBox(width: 12);
      }).toList(),
    );
  }
}

// كلاس لتخزين بيانات كل زرار
class ButtonData {
  final String text;
  final String? iconPath; // الصورة العادية
  final Widget? iconWidget; // SVG أو أي Widget
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? iconWidth;
  final double? iconHeight;
  final double? height;
  final double? borderRadius;

  ButtonData({
    required this.text,
    required this.onTap,
    this.iconPath,
    this.iconWidget,
    this.color,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.iconWidth,
    this.iconHeight,
    this.height,
    this.borderRadius,
  });
}
