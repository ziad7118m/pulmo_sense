import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/models/dashboard_patient_view.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';

class ResolvedPatientAccess {
  final AuthUser user;
  final UserProfile? profile;
  final String matchedBy;

  const ResolvedPatientAccess({
    required this.user,
    required this.profile,
    required this.matchedBy,
  });

  String get fullName => user.displayName.trim().isEmpty ? 'Patient' : user.displayName.trim();

  String get firstName {
    final parts = fullName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    return parts.isEmpty ? 'Patient' : parts.first;
  }

  String get email => user.email.trim();
  String get userId => user.id.trim();
  String get nationalId => (profile?.nationalId ?? '').trim();
  String get avatarPath => (profile?.avatarPath ?? '').trim();
  String get gender => (profile?.gender ?? '').trim();
  String get marital => (profile?.marital ?? '').trim();

  DashboardPatientView toPatientView() {
    return DashboardPatientView(
      userId: userId,
      fullName: fullName,
      email: email,
      nationalId: nationalId,
      gender: gender,
      marital: marital,
      avatarPath: avatarPath,
      matchedBy: matchedBy,
    );
  }
}
