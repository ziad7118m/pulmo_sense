import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_colors.dart';

class ArticleDetailActions extends StatelessWidget {
  final bool isAdmin;
  final bool isOwner;
  final bool isFavorite;
  final bool isSaved;
  final bool isDeleting;
  final bool isTogglingFavourite;
  final bool isTogglingSaved;
  final VoidCallback onToggleFavourite;
  final VoidCallback onToggleSaved;
  final VoidCallback? onDelete;

  const ArticleDetailActions({
    super.key,
    required this.isAdmin,
    required this.isOwner,
    required this.isFavorite,
    required this.isSaved,
    required this.isDeleting,
    required this.isTogglingFavourite,
    required this.isTogglingSaved,
    required this.onToggleFavourite,
    required this.onToggleSaved,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
          IconButton(
            tooltip: isTogglingSaved ? 'Updating save' : 'Save',
            icon: isTogglingSaved
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: isSaved ? scheme.primary : scheme.onSurfaceVariant,
                  ),
            onPressed: isTogglingSaved || isDeleting ? null : onToggleSaved,
          ),
        ],
        if (!isAdmin && isOwner && onDelete != null)
          PopupMenuButton<String>(
            tooltip: isDeleting ? 'Deleting article' : 'More',
            enabled: !isDeleting && !isTogglingFavourite && !isTogglingSaved,
            onSelected: (value) {
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
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
