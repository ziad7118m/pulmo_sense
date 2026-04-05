import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:lung_diagnosis_app/core/session/app_session.dart';
import 'package:lung_diagnosis_app/features/articles/data/local_article.dart';

class ArticleStore {
  static const _boxArticles = 'local_articles';
  static const _boxFavourites = 'article_favourites';
  static const _boxSaved = 'article_saved';

  ArticleStore({required AppSession session}) : _session = session;

  final AppSession _session;
  final ValueNotifier<int> _changes = ValueNotifier<int>(0);

  ValueListenable<int> get changes => _changes;

  Future<Box> _articles() => Hive.openBox(_boxArticles);
  Future<Box> _favourites() => Hive.openBox(_boxFavourites);
  Future<Box> _saved() => Hive.openBox(_boxSaved);

  String _uid() => _session.userId ?? 'anonymous';

  bool _isAdmin() => _session.isAdmin;

  void _notifyChanged() {
    _changes.value = _changes.value + 1;
  }

  Future<List<LocalArticle>> all() async {
    final b = await _articles();
    final items = b.values.whereType<Map>().map(LocalArticle.fromMap).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<List<LocalArticle>> allVisible() async {
    if (_isAdmin()) return all();
    final items = await all();
    return items.where((a) => !a.isHiddenByAdmin).toList();
  }

  Future<List<LocalArticle>> mine() async {
    final uid = _uid();
    final items = await all();
    return items.where((a) => a.createdByUserId == uid).toList();
  }

  Future<List<LocalArticle>> mineVisible() async {
    final items = await mine();
    if (_isAdmin()) return items;
    return items;
  }

  Future<List<LocalArticle>> byAuthor(String userId) async {
    final items = await all();
    return items.where((a) => a.createdByUserId == userId).toList();
  }

  Future<LocalArticle?> getById(String id) async {
    final b = await _articles();
    final raw = b.get(id);
    if (raw is Map) return LocalArticle.fromMap(raw);
    return null;
  }

  Future<void> upsert(LocalArticle article) async {
    final b = await _articles();
    await b.put(article.id, article.toMap());
    _notifyChanged();
  }

  Future<void> delete(String id) async {
    final b = await _articles();
    await b.delete(id);
    _notifyChanged();
  }

  Future<void> setAdminHidden(String articleId, bool hidden) async {
    final a = await getById(articleId);
    if (a == null) return;
    await upsert(
      LocalArticle(
        id: a.id,
        doctorName: a.doctorName,
        title: a.title,
        content: a.content,
        createdAt: a.createdAt,
        createdByUserId: a.createdByUserId,
        doctorImage: a.doctorImage,
        articleImages: a.articleImages,
        articleImage: a.articleImage,
        isHiddenByAdmin: hidden,
      ),
    );
  }

  Future<Set<String>> _favIdsForUser() async {
    final b = await _favourites();
    final raw = b.get(_uid());
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  Future<int> favouriteCount(String articleId) async {
    final b = await _favourites();
    int count = 0;
    for (final k in b.keys) {
      final raw = b.get(k);
      if (raw is List && raw.map((e) => e.toString()).contains(articleId)) {
        count++;
      }
    }
    return count;
  }

  Future<bool> isFavourite(String articleId) async {
    if (_isAdmin()) return false;
    final ids = await _favIdsForUser();
    return ids.contains(articleId);
  }

  Future<void> toggleFavourite(String articleId) async {
    if (_isAdmin()) return;
    final b = await _favourites();
    final ids = await _favIdsForUser();
    if (ids.contains(articleId)) {
      ids.remove(articleId);
    } else {
      ids.add(articleId);
    }
    await b.put(_uid(), ids.toList());
    _notifyChanged();
  }

  Future<void> setFavourite(String articleId, bool isFavourite) async {
    if (_isAdmin()) return;
    final b = await _favourites();
    final ids = await _favIdsForUser();
    if (isFavourite) {
      ids.add(articleId);
    } else {
      ids.remove(articleId);
    }
    await b.put(_uid(), ids.toList());
    _notifyChanged();
  }

  Future<void> replaceFavourites(Iterable<String> articleIds) async {
    if (_isAdmin()) return;
    final b = await _favourites();
    final ids = articleIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    await b.put(_uid(), ids);
    _notifyChanged();
  }

  Future<List<LocalArticle>> favourites() async {
    if (_isAdmin()) return [];
    final ids = await _favIdsForUser();
    if (ids.isEmpty) return [];
    final items = await allVisible();
    return items.where((a) => ids.contains(a.id)).toList();
  }

  Future<Set<String>> _savedIdsForUser() async {
    final b = await _saved();
    final raw = b.get(_uid());
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  Future<bool> isSaved(String articleId) async {
    if (_isAdmin()) return false;
    final ids = await _savedIdsForUser();
    return ids.contains(articleId);
  }

  Future<void> toggleSaved(String articleId) async {
    if (_isAdmin()) return;
    final b = await _saved();
    final ids = await _savedIdsForUser();
    if (ids.contains(articleId)) {
      ids.remove(articleId);
    } else {
      ids.add(articleId);
    }
    await b.put(_uid(), ids.toList());
    _notifyChanged();
  }

  Future<void> setSaved(String articleId, bool isSaved) async {
    if (_isAdmin()) return;
    final b = await _saved();
    final ids = await _savedIdsForUser();
    if (isSaved) {
      ids.add(articleId);
    } else {
      ids.remove(articleId);
    }
    await b.put(_uid(), ids.toList());
    _notifyChanged();
  }

  Future<void> replaceSaved(Iterable<String> articleIds) async {
    if (_isAdmin()) return;
    final b = await _saved();
    final ids = articleIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    await b.put(_uid(), ids);
    _notifyChanged();
  }

  Future<List<LocalArticle>> saved() async {
    if (_isAdmin()) return [];
    final ids = await _savedIdsForUser();
    if (ids.isEmpty) return [];
    final items = await allVisible();
    return items.where((a) => ids.contains(a.id)).toList();
  }
}
