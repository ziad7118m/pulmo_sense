import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lung_diagnosis_app/core/responsive/page_scaffold.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_confirmation_dialog.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_collection_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_feed_list.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_responsive_collection.dart';

class ArticleCollectionScaffold extends StatefulWidget {
  final ArticleCollectionKind kind;
  final WidgetBuilder? emptyActionPageBuilder;
  final WidgetBuilder? floatingActionPageBuilder;

  const ArticleCollectionScaffold({
    super.key,
    required this.kind,
    this.emptyActionPageBuilder,
    this.floatingActionPageBuilder,
  });

  @override
  State<ArticleCollectionScaffold> createState() =>
      _ArticleCollectionScaffoldState();
}

class _ArticleCollectionScaffoldState extends State<ArticleCollectionScaffold> {
  late final ArticleCollectionController _collectionController;
  late Future<List<Article>> _future;
  late final ValueListenable<int> _articleChanges;

  @override
  void initState() {
    super.initState();
    _collectionController = ArticleCollectionController(
      context.read<ArticleController>(),
      kind: widget.kind,
    );
    _future = _collectionController.load();
    _articleChanges = _collectionController.changes;
    _articleChanges.addListener(_handleArticleStoreChanged);
  }

  @override
  void dispose() {
    _articleChanges.removeListener(_handleArticleStoreChanged);
    super.dispose();
  }

  void _handleArticleStoreChanged() {
    if (!mounted) return;
    _refresh(silentError: true);
  }

  Future<void> _refresh({bool silentError = false}) async {
    setState(() {
      _future = _collectionController.load();
    });

    try {
      await _future;
    } catch (error) {
      if (!mounted || silentError) return;
      AppTopMessage.error(context, _errorMessage(error));
    }
  }

  Future<void> _confirmDelete(Article article) async {
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
      await context.read<ArticleController>().delete(article.id);
      if (!mounted) return;
      AppTopMessage.success(context, 'Article deleted');
      await _refresh(silentError: true);
    } catch (error) {
      if (!mounted) return;
      AppTopMessage.error(context, _errorMessage(error));
    }
  }

  void _openPage(WidgetBuilder builder) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: builder),
    );
  }

  Widget _buildEmptyBody() {
    final viewData = _collectionController.viewData;
    final card = Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: EmptyStateCard(
          icon: viewData.emptyIcon,
          title: viewData.emptyTitle,
          message: viewData.emptyMessage,
          actionText: viewData.emptyActionText,
          onAction: widget.emptyActionPageBuilder == null
              ? null
              : () => _openPage(widget.emptyActionPageBuilder!),
        ),
      ),
    );

    if (!viewData.useResponsiveCollection) {
      return card;
    }

    return PageScaffold(
      maxWidth: 900,
      child: card,
    );
  }

  Widget _buildErrorBody(Object error) {
    final viewData = _collectionController.viewData;
    final card = Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: EmptyStateCard(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load articles',
          message: _errorMessage(error),
          actionText: 'Try again',
          onAction: () => _refresh(),
        ),
      ),
    );

    if (!viewData.useResponsiveCollection) {
      return card;
    }

    return PageScaffold(
      maxWidth: 900,
      child: card,
    );
  }

  Widget _buildBody(List<Article> items) {
    final viewData = _collectionController.viewData;
    if (viewData.useResponsiveCollection) {
      return ArticleResponsiveCollection(
        articles: items,
        onArticleMutated: _refresh,
      );
    }

    return ArticleFeedList(
      articles: items,
      showOwnerDelete: viewData.showOwnerDelete,
      showHiddenBadge: viewData.showHiddenBadge,
      onDeleteRequested: viewData.showOwnerDelete ? _confirmDelete : null,
      onArticleMutated: _refresh,
    );
  }

  String _errorMessage(Object error) {
    final message = error.toString().trim();
    if (message.isEmpty) {
      return 'Please check your connection and try again.';
    }
    if (message.startsWith('Exception:')) {
      final cleaned = message.replaceFirst('Exception:', '').trim();
      if (cleaned.isNotEmpty) return cleaned;
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final viewData = _collectionController.viewData;

    return Scaffold(
      appBar: CustomAppBar(
        title: viewData.title,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Article>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(children: [_buildErrorBody(snap.error!)]),
            );
          }

          final items = snap.data ?? const <Article>[];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(children: [_buildEmptyBody()]),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _buildBody(items),
          );
        },
      ),
      floatingActionButton: widget.floatingActionPageBuilder == null
          ? null
          : FloatingActionButton(
              onPressed: () => _openPage(widget.floatingActionPageBuilder!),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
    );
  }
}
