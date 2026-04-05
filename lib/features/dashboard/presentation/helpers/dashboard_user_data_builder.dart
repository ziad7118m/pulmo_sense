import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/models/dashboard_patient_view.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/models/user_info_data.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class DashboardUserDataBuilder {
  const DashboardUserDataBuilder._();

  static UserInfoData build({
    required AuthUser? currentUser,
    required UserProfile? currentProfile,
    required DashboardPatientView? patientView,
  }) {
    if (patientView != null) {
      return UserInfoData(
        fullName: patientView.fullName,
        email: patientView.email,
        nationalId: patientView.nationalId,
        gender: patientView.gender,
        marital: patientView.marital,
        roleText: 'Patient',
        accountId: patientView.userId,
        avatarPath: patientView.avatarPath,
      );
    }

    final user = currentUser;
    final profile = currentProfile;

    final normalizedName = (user?.displayName ?? '').trim();

    return UserInfoData(
      fullName: normalizedName.isEmpty ? 'User' : normalizedName,
      email: user?.email ?? '',
      nationalId: profile?.nationalId ?? '',
      gender: profile?.gender ?? '',
      marital: profile?.marital ?? '',
      roleText: user?.role.displayName ?? 'Patient',
      accountId: user?.id ?? '',
      avatarPath: profile?.avatarPath ?? '',
    );
  }
}
