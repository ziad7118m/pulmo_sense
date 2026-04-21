import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_image.dart';

class ArticleCardThumbnail extends StatelessWidget {
  final String articleImage;

  const ArticleCardThumbnail({
    super.key,
    required this.articleImage,
  });

  bool _hasImage(String path) {
    final normalized = path.trim();
    return normalized.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasArticleImage = _hasImage(articleImage);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: hasArticleImage
          ? AppImage(
              path: articleImage,
              width: 84,
              height: 84,
              fit: BoxFit.cover,
              errorLabel: '',
            )
          : Container(
              width: 84,
              height: 84,
              color: scheme.primaryContainer,
              child: Icon(
                Icons.image_outlined,
                color: scheme.primary,
              ),
            ),
    );
  }
}
