import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_feed_card.dart';

class ArticleFeedList extends StatelessWidget {
  final List<Article> articles;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry itemPadding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool separated;
  final bool showOwnerDelete;
  final bool showHiddenBadge;
  final bool preferCurrentUserAvatar;
  final Future<void> Function(Article article)? onDeleteRequested;
  final Future<void> Function()? onArticleMutated;

  const ArticleFeedList({
    super.key,
    required this.articles,
    this.padding = const EdgeInsets.all(8),
    this.itemPadding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.physics,
    this.separated = false,
    this.showOwnerDelete = false,
    this.showHiddenBadge = false,
    this.preferCurrentUserAvatar = true,
    this.onDeleteRequested,
    this.onArticleMutated,
  });

  Widget _buildCard(Article article) {
    return Padding(
      padding: itemPadding,
      child: ArticleFeedCard(
        article: article,
        showOwnerDelete: showOwnerDelete,
        showHiddenBadge: showHiddenBadge,
        preferCurrentUserAvatar: preferCurrentUserAvatar,
        onDeleteRequested: onDeleteRequested,
        onArticleMutated: onArticleMutated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (separated) {
      return ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildCard(articles[index]),
      );
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: articles.length,
      itemBuilder: (context, index) => _buildCard(articles[index]),
    );
  }
}
