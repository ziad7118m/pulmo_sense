import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/widgets/app_confirmation_dialog.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_feed_card.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/controllers/admin_doctor_articles_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_doctor_articles_view_data.dart';
import 'package:provider/provider.dart';

class AdminDoctorArticlesSection extends StatefulWidget {
  final String doctorUserId;

  const AdminDoctorArticlesSection({
    super.key,
    required this.doctorUserId,
  });

  @override
  State<AdminDoctorArticlesSection> createState() => _AdminDoctorArticlesSectionState();
}

class _AdminDoctorArticlesSectionState extends State<AdminDoctorArticlesSection> {
  late final AdminDoctorArticlesController _controller;
  late Future<AdminDoctorArticlesViewData> _future;
  late final ValueListenable<int> _articleChanges;
  final Set<String> _busyArticleIds = <String>{};

  @override
  void initState() {
    super.initState();
    _controller = AdminDoctorArticlesController(
      context.read<ArticleController>(),
      doctorUserId: widget.doctorUserId,
    );
    _future = _controller.load();
    _articleChanges = _controller.changes;
    _articleChanges.addListener(_handleArticleStoreChanged);
  }

  @override
  void dispose() {
    _articleChanges.removeListener(_handleArticleStoreChanged);
    super.dispose();
  }

  void _handleArticleStoreChanged() {
    if (!mounted) return;
    _refresh();
  }

  Future<void> _refresh({bool showErrorMessage = false}) async {
    final future = _controller.load();
    setState(() {
      _future = future;
    });

    try {
      await future;
    } catch (_) {
      if (!mounted || !showErrorMessage) return;
      AppTopMessage.error(context, 'Unable to load doctor articles right now.');
    }
  }

  bool _isBusy(String articleId) => _busyArticleIds.contains(articleId);

  Future<void> _runArticleAction(
    String articleId,
    Future<void> Function() action, {
    required String successMessage,
    required String errorMessage,
  }) async {
    if (_isBusy(articleId)) return;

    setState(() {
      _busyArticleIds.add(articleId);
    });

    try {
      await action();
      if (!mounted) return;
      AppTopMessage.success(context, successMessage);
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      AppTopMessage.error(context, errorMessage);
    } finally {
      if (!mounted) return;
      setState(() {
        _busyArticleIds.remove(articleId);
      });
    }
  }

  Future<void> _toggleHidden(Article article) {
    return _runArticleAction(
      article.id,
      () => _controller.toggleHidden(article),
      successMessage: !article.isHiddenByAdmin ? 'Article hidden' : 'Article visible',
      errorMessage: 'Unable to update article visibility.',
    );
  }

  Future<void> _delete(Article article) async {
    if (_isBusy(article.id)) return;

    final ok = await AppConfirmationDialog.show(
      context,
      title: 'Delete article?',
      message: 'This will permanently delete the article from records.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok) return;

    await _runArticleAction(
      article.id,
      () => _controller.delete(article),
      successMessage: 'Article deleted',
      errorMessage: 'Unable to delete the article.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? scheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.article_outlined, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor articles',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: scheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Moderate visibility or delete content authored by this doctor.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => _refresh(showErrorMessage: true),
                icon: Icon(Icons.refresh_rounded, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<AdminDoctorArticlesViewData>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: CircularProgressIndicator()),
                );
              }


              if (snap.hasError) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.error.withOpacity(0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unable to load doctor articles.',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Check the connection or try again.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonalIcon(
                          onPressed: () => _refresh(showErrorMessage: true),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final data = snap.data;
              final items = data?.items ?? const <Article>[];

              if (items.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'No articles available yet for this doctor.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _metricChip(
                          context,
                          label: 'Articles',
                          value: '${data?.totalCount ?? items.length}',
                          icon: Icons.feed_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _metricChip(
                          context,
                          label: 'Visible',
                          value: '${data?.visibleCount ?? 0}',
                          icon: Icons.visibility_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _metricChip(
                          context,
                          label: 'Hidden',
                          value: '${data?.hiddenCount ?? 0}',
                          icon: Icons.visibility_off_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final article = items[index];
                      final isBusy = _isBusy(article.id);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ArticleFeedCard(
                            article: article,
                            showHiddenBadge: true,
                            preferCurrentUserAvatar: false,
                            onArticleMutated: _refresh,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: isBusy ? null : () => _toggleHidden(article),
                                  icon: isBusy
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(
                                          article.isHiddenByAdmin
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                        ),
                                  label: Text(article.isHiddenByAdmin ? 'Show article' : 'Hide article'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: isBusy ? null : () => _delete(article),
                                  icon: isBusy
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.delete_outline_rounded),
                                  label: const Text('Delete'),
                                  style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metricChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
