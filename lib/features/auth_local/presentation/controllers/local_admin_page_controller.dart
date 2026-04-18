import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/helpers/admin_dashboard_loader.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_users_kind.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/local_admin_page_view_data.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_home_tile.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/admin_insight_panel.dart';

class LocalAdminPageController {
  final AuthController _authController;

  const LocalAdminPageController({
    required AuthController authController,
  }) : _authController = authController;

  bool get isApiMode => _authController.isApiMode;

  Future<LocalAdminPageViewData> loadViewData() async {
    final snapshot = await loadAdminDashboardSnapshot(
      authController: _authController,
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
    final accents = <AdminUsersKind, Color>{
      AdminUsersKind.pending: const Color(0xFFFF9800),
      AdminUsersKind.active: const Color(0xFF1E88E5),
      AdminUsersKind.doctors: const Color(0xFF00897B),
      AdminUsersKind.patients: const Color(0xFF5E60CE),
      AdminUsersKind.disabled: const Color(0xFF6D4C41),
      AdminUsersKind.rejected: const Color(0xFFD32F2F),
      AdminUsersKind.deleted: const Color(0xFF8E24AA),
    };

    return AdminUsersKind.values
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
        .toList(growable: false);
  }

  List<AdminInsightItem> buildInsightItems(LocalAdminPageViewData data) {
    return [
      AdminInsightItem(
        label: 'Total accounts',
        value: '${data.totalUsers}',
        icon: Icons.groups_rounded,
      ),
      AdminInsightItem(
        label: 'Approved users',
        value: '${data.snapshot.approved}',
        icon: Icons.verified_user_rounded,
      ),
      AdminInsightItem(
        label: 'Deleted users',
        value: '${data.snapshot.deleted}',
        icon: Icons.delete_sweep_rounded,
      ),
    ];
  }
}
