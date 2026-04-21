import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_colors.dart';

class ArticleDetailActions extends StatelessWidget {
  final bool isAdmin;
  final bool isOwner;
  final bool isFavorite;
  final bool isDeleting;
  final bool isTogglingFavourite;
  final VoidCallback onToggleFavourite;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ArticleDetailActions({
    super.key,
    required this.isAdmin,
    required this.isOwner,
    required this.isFavorite,
    required this.isDeleting,
    required this.isTogglingFavourite,
    required this.onToggleFavourite,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canShowOwnerMenu = isOwner && (onEdit != null || onDelete != null);
    final canDelete = (isOwner || isAdmin) && onDelete != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isAdmin) ...[
          IconButton(
            tooltip: isTogglingFavourite ? 'Updating favourite' : 'Favourite',
            icon: isTogglingFavourite
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? AppColors.red : scheme.onSurfaceVariant,
                  ),
            onPressed: isTogglingFavourite || isDeleting ? null : onToggleFavourite,
          ),
        ],
        if (canShowOwnerMenu || canDelete)
          PopupMenuButton<String>(
            tooltip: isDeleting ? 'Updating article' : 'More',
            enabled: !isDeleting && !isTogglingFavourite,
            onSelected: (value) {
              if (value == 'edit') onEdit?.call();
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (_) => [
              if (canShowOwnerMenu && onEdit != null)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
              if (canDelete)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.more_vert_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
            ),
          ),
      ],
    );
  }
}
