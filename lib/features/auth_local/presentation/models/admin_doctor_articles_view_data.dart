import 'package:lung_diagnosis_app/features/articles/domain/entities/article.dart';

class AdminDoctorArticlesViewData {
  final List<Article> items;
  final int hiddenCount;
  final int visibleCount;

  const AdminDoctorArticlesViewData({
    required this.items,
    required this.hiddenCount,
    required this.visibleCount,
  });

  bool get isEmpty => items.isEmpty;
  int get totalCount => items.length;
}
