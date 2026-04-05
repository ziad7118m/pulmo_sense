import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/responsive/page_scaffold.dart';
import 'package:lung_diagnosis_app/core/responsive/responsive_shell.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_feed_card.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_feed_list.dart';

class ArticleResponsiveCollection extends StatelessWidget {
  final List<Article> articles;
  final Future<void> Function()? onArticleMutated;

  const ArticleResponsiveCollection({
    super.key,
    required this.articles,
    this.onArticleMutated,
  });

  Widget _buildGrid({required int columns}) {
    return PageScaffold(
      maxWidth: 1200,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: articles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 2 ? 1.25 : 1.35,
        ),
        itemBuilder: (context, index) => ArticleFeedCard(
          article: articles[index],
          onArticleMutated: onArticleMutated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      mobile: ArticleFeedList(
        articles: articles,
        onArticleMutated: onArticleMutated,
      ),
      tablet: _buildGrid(columns: 2),
      desktop: _buildGrid(columns: 3),
    );
  }
}
