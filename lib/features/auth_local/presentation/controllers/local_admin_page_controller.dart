import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/helpers/admin_dashboard_loader.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_users_kind.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/local_admin_page_view_data.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_home_tile.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_insight_panel.dart';

class LocalAdminPageController {
  final AuthController _authController;
  final ArticleController _articleController;

  const LocalAdminPageController({
    required AuthController authController,
    required ArticleController articleController,
  }) : _authController = authController,
       _articleController = articleController;

  bool get isApiMode => _authController.isApiMode;

  Future<LocalAdminPageViewData> loadViewData() async {
    final snapshot = await loadAdminDashboardSnapshot(
      authController: _authController,
      articleController: _articleController,
    );

    return LocalAdminPageViewData(snapshot: snapshot);
  }

  Future<void> logout() {
    return _authController.logout();
  }

  List<AdminHomeTileData> buildTiles({
    required LocalAdminPageViewData data,
    required void Function(AdminUsersKind kind) onOpenUsers,
  }) {
    final counts = data.snapshot.userCounts;
    final kinds = AdminUsersKind.values;

    final accents = <AdminUsersKind, Color>{
      AdminUsersKind.pending: const Color(0xFFFFA000),
      AdminUsersKind.active: const Color(0xFF1976D2),
      AdminUsersKind.disabled: const Color(0xFF546E7A),
      AdminUsersKind.rejected: const Color(0xFFD32F2F),
      AdminUsersKind.doctors: const Color(0xFF0F8B8D),
      AdminUsersKind.patients: const Color(0xFF5E60CE),
    };

    return kinds
        .map(
          (kind) => AdminHomeTileData(
            title: kind.title,
            subtitle: kind.tileSubtitle,
            icon: kind.tileIcon,
            countLabel: '${counts[kind] ?? 0}',
            accentColor: accents[kind],
            onTap: () => onOpenUsers(kind),
          ),
        )
        .toList();
  }

  List<AdminInsightItem> buildInsightItems(LocalAdminPageViewData data) {
    return [
      AdminInsightItem(
        label: 'Visible posts',
        value: '${data.snapshot.visibleArticles}',
        icon: Icons.visibility_rounded,
      ),
      AdminInsightItem(
        label: 'Hidden posts',
        value: '${data.snapshot.hiddenArticles}',
        icon: Icons.visibility_off_rounded,
      ),
      AdminInsightItem(
        label: 'Total posts',
        value: '${data.snapshot.totalArticles}',
        icon: Icons.feed_outlined,
      ),
    ];
  }
}
