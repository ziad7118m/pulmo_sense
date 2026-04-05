import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_author_header.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_gallery.dart';

class ArticleDetailContent extends StatelessWidget {
  final Article article;
  final String doctorImagePath;
  final String createdAtText;
  final List<String> images;
  final int activeIndex;
  final ValueChanged<int> onPageChanged;

  const ArticleDetailContent({
    super.key,
    required this.article,
    required this.doctorImagePath,
    required this.createdAtText,
    required this.images,
    required this.activeIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArticleAuthorHeader(
          doctorName: article.doctorName,
          doctorImagePath: doctorImagePath,
          createdAtText: createdAtText,
          isHiddenByAdmin: article.isHiddenByAdmin,
        ),
        const SizedBox(height: 24),
        Text(
          article.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: scheme.onSurface,
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 18),
          ArticleGallery(
            images: images,
            activeIndex: activeIndex,
            onPageChanged: onPageChanged,
          ),
        ],
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            article.content,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.75,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
