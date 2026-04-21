import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_card_header.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_card_thumbnail.dart';

class ArticleCard extends StatelessWidget {
  final String articleId;
  final String doctorImage;
  final String doctorName;
  final String title;
  final String preview;
  final String articleImage;
  final bool isAdmin;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showOwnerDelete;
  final bool showHiddenBadge;
  final bool isHiddenByAdmin;

  const ArticleCard({
    super.key,
    required this.articleId,
    required this.doctorImage,
    required this.doctorName,
    required this.title,
    required this.preview,
    required this.articleImage,
    required this.isAdmin,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showOwnerDelete = false,
    this.showHiddenBadge = false,
    this.isHiddenByAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  scheme.surface,
                  scheme.surfaceVariant.withOpacity(0.82),
                ]
              : const [
                  Color(0xFFFFFFFF),
                  Color(0xFFF5FAFF),
                ],
        ),
        border: Border.all(
          color: isDark
              ? scheme.outlineVariant.withOpacity(0.78)
              : const Color(0xFFD7E7FF),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.05),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ArticleCardHeader(
                        doctorImage: doctorImage,
                        doctorName: doctorName,
                        showHiddenBadge: showHiddenBadge && isAdmin,
                        isHiddenByAdmin: isHiddenByAdmin,
                        showOwnerDelete: showOwnerDelete,
                        onEdit: onEdit,
                        onDelete: onDelete,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                          height: 1.22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ArticleCardThumbnail(articleImage: articleImage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
