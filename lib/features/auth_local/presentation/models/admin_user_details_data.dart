import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_info_row.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';

class AdminUserDetailsData {
  final UserProfile profile;
  final int articleCount;
  final List<AdminInfoRow> accountRows;
  final List<AdminInfoRow> profileRows;
  final List<AdminInfoRow> insightRows;

  const AdminUserDetailsData({
    required this.profile,
    required this.articleCount,
    required this.accountRows,
    required this.profileRows,
    required this.insightRows,
  });
}
