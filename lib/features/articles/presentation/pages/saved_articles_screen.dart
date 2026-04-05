import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_collection_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/articles_screen.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_collection_scaffold.dart';

class SavedArticlesScreen extends StatelessWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleCollectionScaffold(
      kind: ArticleCollectionKind.saved,
      emptyActionPageBuilder: _articlesScreenBuilder,
    );
  }
}

Widget _articlesScreenBuilder(BuildContext context) => const ArticlesScreen();
