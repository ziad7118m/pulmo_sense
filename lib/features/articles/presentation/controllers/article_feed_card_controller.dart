import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/helpers/article_media_resolver.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/models/article_feed_card_view_data.dart';

class ArticleFeedCardController {
  final Article article;
  final bool preferCurrentUserAvatar;
  final String? currentUserId;
  final String currentUserAvatarPath;
  final bool isAdmin;

  const ArticleFeedCardController({
    required this.article,
    required this.preferCurrentUserAvatar,
    required this.currentUserId,
    required this.currentUserAvatarPath,
    required this.isAdmin,
  });

  ArticleFeedCardViewData build() {
    return ArticleFeedCardViewData(
      doctorImage: ArticleMediaResolver.resolveDoctorImageForUserContext(
        article: article,
        currentUserId: currentUserId,
        currentUserAvatarPath: currentUserAvatarPath,
        preferCurrentUserAvatar: preferCurrentUserAvatar,
      ),
      articleImage: ArticleMediaResolver.resolveArticleImage(article),
      isAdmin: isAdmin,
    );
  }
}
