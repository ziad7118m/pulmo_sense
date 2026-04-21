import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_confirmation_dialog.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_detail_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/add_article_screen.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_detail_actions.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_detail_content.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late final ArticleDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ArticleDetailController(
      article: widget.article,
      articleController: context.read<ArticleController>(),
      authController: context.read<AuthController>(),
      context: context,
    );
    _controller.initialize();
  }

  Future<void> _deleteArticle() async {
    final ok = await AppConfirmationDialog.show(
      context,
      title: 'Delete article?',
      message: 'This will permanently delete the article.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok) return;

    try {
      final deleted = await _controller.delete();
      if (!mounted || !deleted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      AppTopMessage.error(context, 'Could not delete the article. Please try again.');
    }
  }

  Future<void> _editArticle() async {
    final updated = await Navigator.push<Article>(
      context,
      MaterialPageRoute(
        builder: (_) => AddArticleScreen(initialArticle: _controller.article),
      ),
    );

    if (!mounted || updated == null) return;
    _controller.replaceArticle(updated);
    AppTopMessage.success(context, 'Article updated');
  }

  Future<void> _toggleFavourite() async {
    try {
      final isFavorite = await _controller.toggleFavourite();
      if (!mounted) return;
      AppTopMessage.success(
        context,
        isFavorite ? AppStrings.addedFavourite : AppStrings.removedFavourite,
      );
    } catch (_) {
      if (!mounted) return;
      AppTopMessage.error(context, 'Could not update favourites right now.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final data = _controller.viewData;

        if (data.isHiddenForCurrentUser) {
          return Scaffold(
            appBar: CustomAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: AppStrings.article,
            ),
            body: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: EmptyStateCard(
                  icon: Icons.visibility_off_rounded,
                  title: 'Article hidden',
                  message: 'This article is temporarily hidden by the admin.',
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: AppStrings.article,
            actions: [
              ArticleDetailActions(
                isAdmin: data.isAdmin,
                isOwner: data.isOwner,
                isFavorite: data.isFavorite,
                isDeleting: data.isDeleting,
                isTogglingFavourite: data.isTogglingFavourite,
                onToggleFavourite: _toggleFavourite,
                onEdit: data.isOwner ? _editArticle : null,
                onDelete: _deleteArticle,
              ),
            ],
          ),
          body: IgnorePointer(
            ignoring: data.isDeleting,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: ArticleDetailContent(
                article: _controller.article,
                doctorImagePath: data.doctorImagePath,
                createdAtText: data.createdAtText,
                images: data.images,
                activeIndex: data.activeImageIndex,
                onPageChanged: _controller.updateImageIndex,
              ),
            ),
          ),
        );
      },
    );
  }
}
