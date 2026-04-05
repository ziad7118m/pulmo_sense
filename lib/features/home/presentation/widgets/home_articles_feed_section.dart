import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_section.dart';

class HomeArticlesFeedSection extends StatelessWidget {
  final VoidCallback onSeeAll;

  const HomeArticlesFeedSection({
    super.key,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return ArticlesSection(
      title: AppStrings.medicalArticles,
      onSeeAll: onSeeAll,
    );
  }
}
