import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_feed_card_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/helpers/article_media_resolver.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/article_detail_screen.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_card.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class ArticleFeedCard extends StatelessWidget {
  final Article article;
  final bool showOwnerDelete;
  final bool showHiddenBadge;
  final bool preferCurrentUserAvatar;
  final Future<void> Function(Article article)? onDeleteRequested;
  final Future<void> Function()? onArticleMutated;

  const ArticleFeedCard({
    super.key,
    required this.article,
    this.showOwnerDelete = false,
    this.showHiddenBadge = false,
    this.preferCurrentUserAvatar = true,
    this.onDeleteRequested,
    this.onArticleMutated,
  });

  Future<void> _openArticle(BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
    );
    if (changed == true) {
      await onArticleMutated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final viewData = ArticleFeedCardController(
      article: article,
      preferCurrentUserAvatar: preferCurrentUserAvatar,
      currentUserId: auth.currentUserId,
      currentUserAvatarPath: ArticleMediaResolver.resolveCurrentDoctorAvatar(context),
      isAdmin: auth.isAdmin,
    ).build();

    return ArticleCard(
      articleId: article.id,
      doctorImage: viewData.doctorImage,
      doctorName: article.doctorName,
      title: article.title,
      preview: article.preview,
      articleImage: viewData.articleImage,
      isAdmin: viewData.isAdmin,
      showOwnerDelete: showOwnerDelete,
      onDelete: onDeleteRequested == null ? null : () => onDeleteRequested!(article),
      showHiddenBadge: showHiddenBadge,
      isHiddenByAdmin: article.isHiddenByAdmin,
      onTap: () => _openArticle(context),
    );
  }
}
