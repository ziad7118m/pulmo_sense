import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_dashboard_snapshot.dart';

class LocalAdminPageViewData {
  final AdminDashboardSnapshot snapshot;

  const LocalAdminPageViewData({required this.snapshot});

  int get totalActiveUsers => snapshot.doctors + snapshot.patients;
}
