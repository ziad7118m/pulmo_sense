import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/empty_state_card.dart';
import 'package:lung_diagnosis_app/core/widgets/text_button.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_section_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/models/article_section_view_data.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_feed_list.dart';
import 'package:provider/provider.dart';

class ArticlesSection extends StatefulWidget {
  final String title;
  final VoidCallback onSeeAll;
  final int limit;

  const ArticlesSection({
    super.key,
    required this.title,
    required this.onSeeAll,
    this.limit = 2,
  });

  @override
  State<ArticlesSection> createState() => _ArticlesSectionState();
}

class _ArticlesSectionState extends State<ArticlesSection> {
  late final ArticleSectionController _controller;
  late Future<ArticleSectionViewData> _future;
  late final ValueListenable<int> _articleChanges;

  @override
  void initState() {
    super.initState();
    _controller = ArticleSectionController(
      context.read<ArticleController>(),
      limit: widget.limit,
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
    setState(() {
      _future = _controller.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              CustomTextButton(
                text: AppStrings.seeAllBtn,
                fontSize: 12,
                onPressed: widget.onSeeAll,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<ArticleSectionViewData>(
          future: _future,
          builder: (context, snap) {
            final data = snap.data;
            final items = data?.items ?? const [];
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: EmptyStateCard(
                  icon: Icons.article_outlined,
                  title: 'No articles available',
                  message: 'Articles will show up here once they are added.',
                ),
              );
            }
            return ArticleFeedList(
              articles: items,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemPadding: const EdgeInsets.symmetric(horizontal: 10),
              preferCurrentUserAvatar: false,
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
