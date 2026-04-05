import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article_draft.dart';
import 'package:lung_diagnosis_app/features/articles/domain/repositories/article_repository.dart';

class ArticleController extends ChangeNotifier {
  final ArticleRepository _repository;

  ArticleController(this._repository);

  ValueListenable<int> get changes => _repository.changes;

  Future<List<Article>> all() => _repository.all();
  Future<List<Article>> allVisible() => _repository.allVisible();
  Future<List<Article>> mineVisible() => _repository.mineVisible();
  Future<List<Article>> favourites() => _repository.favourites();
  Future<List<Article>> saved() => _repository.saved();
  Future<List<Article>> byAuthor(String userId) => _repository.byAuthor(userId);
  Future<Article?> getById(String id) => _repository.getById(id);

  Future<Article> createFromDraft(ArticleDraft draft) async {
    final created = await _repository.createFromDraft(draft);
    notifyListeners();
    return created;
  }

  Future<void> delete(String articleId) async {
    await _repository.delete(articleId);
    notifyListeners();
  }

  Future<void> setAdminHidden(String articleId, bool hidden) async {
    await _repository.setAdminHidden(articleId, hidden);
    notifyListeners();
  }

  Future<int> favouriteCount(String articleId) => _repository.favouriteCount(articleId);
  Future<bool> isFavourite(String articleId) => _repository.isFavourite(articleId);
  Future<bool> isSaved(String articleId) => _repository.isSaved(articleId);

  Future<void> toggleFavourite(String articleId) async {
    await _repository.toggleFavourite(articleId);
    notifyListeners();
  }

  Future<void> toggleSaved(String articleId) async {
    await _repository.toggleSaved(articleId);
    notifyListeners();
  }
}
