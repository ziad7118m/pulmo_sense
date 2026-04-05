import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_doctor_articles_view_data.dart';

class AdminDoctorArticlesController {
  final ArticleController _articles;
  final String doctorUserId;

  const AdminDoctorArticlesController(
    this._articles, {
    required this.doctorUserId,
  });

  ValueListenable<int> get changes => _articles.changes;

  Future<AdminDoctorArticlesViewData> load() async {
    final items = await _articles.byAuthor(doctorUserId);
    final hiddenCount = items.where((article) => article.isHiddenByAdmin).length;
    return AdminDoctorArticlesViewData(
      items: items,
      hiddenCount: hiddenCount,
      visibleCount: items.length - hiddenCount,
    );
  }

  Future<void> toggleHidden(Article article) {
    return _articles.setAdminHidden(article.id, !article.isHiddenByAdmin);
  }

  Future<void> delete(Article article) {
    return _articles.delete(article.id);
  }
}
