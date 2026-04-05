import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_dashboard_snapshot.dart';

Future<AdminDashboardSnapshot> loadAdminDashboardSnapshot({
  required AuthController authController,
  required ArticleController articleController,
}) async {
  try {
    final pending = await authController.fetchPending();
    final approved = await authController.fetchApproved();
    final disabled = await authController.fetchDisabled();
    final rejected = await authController.fetchRejected();
    final doctors = await authController.fetchDoctors();
    final patients = await authController.fetchPatients();
    final allArticles = await articleController.all();
    final hiddenArticles = allArticles.where((article) => article.isHiddenByAdmin).length;
    final visibleArticles = allArticles.length - hiddenArticles;

    return AdminDashboardSnapshot(
      pending: pending.length,
      approved: approved.length,
      disabled: disabled.length,
      rejected: rejected.length,
      doctors: doctors.length,
      patients: patients.length,
      totalArticles: allArticles.length,
      hiddenArticles: hiddenArticles,
      visibleArticles: visibleArticles,
    );
  } catch (_) {
    return const AdminDashboardSnapshot();
  }
}
