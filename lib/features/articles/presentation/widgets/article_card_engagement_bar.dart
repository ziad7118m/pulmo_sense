import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:provider/provider.dart';

class ArticleCardEngagementBar extends StatefulWidget {
  final String articleId;

  const ArticleCardEngagementBar({
    super.key,
    required this.articleId,
  });

  @override
  State<ArticleCardEngagementBar> createState() => _ArticleCardEngagementBarState();
}

class _ArticleCardEngagementBarState extends State<ArticleCardEngagementBar> {
  late Future<_ArticleEngagementSnapshot> _snapshotFuture;
  late final ValueNotifier<int> _articleChanges;

  bool _isFavouriteBusy = false;

  bool get _isBusy => _isFavouriteBusy;

  @override
  void initState() {
    super.initState();
    final controller = context.read<ArticleController>();
    _snapshotFuture = _loadSnapshot();
    _articleChanges = controller.changes as ValueNotifier<int>;
    _articleChanges.addListener(_handleArticleStoreChanged);
  }

  @override
  void dispose() {
    _articleChanges.removeListener(_handleArticleStoreChanged);
    super.dispose();
  }

  void _handleArticleStoreChanged() {
    if (!mounted) return;
    _reload();
  }

  Future<_ArticleEngagementSnapshot> _loadSnapshot() async {
    final controller = context.read<ArticleController>();
    final favouriteCount = await controller.favouriteCount(widget.articleId);
    final isFavourite = await controller.isFavourite(widget.articleId);

    return _ArticleEngagementSnapshot(
      favouriteCount: favouriteCount,
      isFavourite: isFavourite,
    );
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _snapshotFuture = _loadSnapshot();
    });
  }

  Future<void> _toggleFavourite() async {
    if (_isBusy) return;

    setState(() => _isFavouriteBusy = true);
    try {
      await context.read<ArticleController>().toggleFavourite(widget.articleId);
      await _reload();
    } catch (_) {
      _showActionError('Failed to update favourites.');
    } finally {
      if (mounted) {
        setState(() => _isFavouriteBusy = false);
      }
    }
  }


  void _showActionError(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<_ArticleEngagementSnapshot>(
      future: _snapshotFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError && !snapshot.hasData) {
          return Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: scheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Could not load engagement.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: _isBusy ? null : _reload,
                child: const Text('Retry'),
              ),
            ],
          );
        }

        final data = snapshot.data ?? const _ArticleEngagementSnapshot();
        final isBusy = _isBusy;

        return AnimatedOpacity(
          opacity: isBusy ? 0.7 : 1,
          duration: const Duration(milliseconds: 160),
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: isBusy ? null : _toggleFavourite,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      if (_isFavouriteBusy)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          data.isFavourite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color:
                              data.isFavourite ? Colors.red : scheme.onSurfaceVariant,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        '${data.favouriteCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArticleEngagementSnapshot {
  final int favouriteCount;
  final bool isFavourite;

  const _ArticleEngagementSnapshot({
    this.favouriteCount = 0,
    this.isFavourite = false,
  });
}
