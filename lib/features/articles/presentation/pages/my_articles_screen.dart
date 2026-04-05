import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_collection_controller.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/pages/add_article_screen.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/widgets/article_collection_scaffold.dart';

class MyArticlesScreen extends StatelessWidget {
  const MyArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleCollectionScaffold(
      kind: ArticleCollectionKind.mineVisible,
      emptyActionPageBuilder: _addArticleScreenBuilder,
      floatingActionPageBuilder: _addArticleScreenBuilder,
    );
  }
}

Widget _addArticleScreenBuilder(BuildContext context) => const AddArticleScreen();
