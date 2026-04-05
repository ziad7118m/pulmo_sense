import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_image.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/models/menu_action_item.dart';

class MenuItemWidget extends StatelessWidget {
  final MenuActionItem? item;
  final String? imagePath;
  final IconData? leadingIcon;
  final String? title;
  final VoidCallback? onTap;

  const MenuItemWidget({
    super.key,
    this.item,
    this.imagePath,
    this.leadingIcon,
    this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveTitle = item?.title ?? title ?? '';
    final effectiveOnTap = item?.onTap ?? onTap ?? () {};
    final effectiveIcon = item?.icon ?? leadingIcon;
    final isDestructive = item?.isDestructive ?? false;

    Widget leading = const SizedBox.shrink();
    if (effectiveIcon != null) {
      leading = Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDestructive
              ? scheme.errorContainer.withOpacity(0.9)
              : scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(
          effectiveIcon,
          color: isDestructive ? scheme.error : scheme.primary,
          size: 22,
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      leading = Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: AppImage(
          path: imagePath!,
          fit: BoxFit.contain,
          width: 22,
          height: 22,
          color: scheme.primary,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: effectiveOnTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              leading,
              if (leading is! SizedBox) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  effectiveTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? scheme.error : scheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
