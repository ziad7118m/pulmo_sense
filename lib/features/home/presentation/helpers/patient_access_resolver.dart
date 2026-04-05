import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/home/presentation/models/resolved_patient_access.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';

class PatientAccessResolver {
  const PatientAccessResolver._();

  static Future<ResolvedPatientAccess?> resolve({
    required String patientId,
    required String nationalId,
    required ProfileRepository profileRepository,
    required AuthController authController,
  }) async {
    final normalizedPatientId = patientId.trim();
    final normalizedNationalId = nationalId.trim();

    if (normalizedPatientId.isEmpty && normalizedNationalId.isEmpty) {
      return null;
    }

    final byId = normalizedPatientId.isNotEmpty
        ? await authController.findApprovedPatientById(normalizedPatientId)
        : null;

    final byNationalId = normalizedNationalId.isNotEmpty
        ? await authController.findApprovedPatientByNationalId(
            normalizedNationalId,
            resolveUserId: profileRepository.findUserIdByNationalId,
          )
        : null;

    final AuthUser? resolvedUser = _resolveMatch(byId, byNationalId);
    final matchedBy = _matchedByLabel(byId: byId, byNationalId: byNationalId);

    if (resolvedUser == null || matchedBy == null) return null;

    UserProfile? profile;
    try {
      profile = await profileRepository.getProfile(resolvedUser.id);
    } catch (_) {
      profile = null;
    }

    return ResolvedPatientAccess(
      user: resolvedUser,
      profile: profile,
      matchedBy: matchedBy,
    );
  }

  static AuthUser? _resolveMatch(AuthUser? byId, AuthUser? byNationalId) {
    if (byId == null) return byNationalId;
    if (byNationalId == null) return byId;

    final leftId = byId.id.trim();
    final rightId = byNationalId.id.trim();
    if (leftId.isEmpty || rightId.isEmpty || leftId != rightId) {
      return null;
    }
    return byId;
  }

  static String? _matchedByLabel({
    required Object? byId,
    required Object? byNationalId,
  }) {
    if (byId != null && byNationalId != null) {
      return 'Patient ID + National ID';
    }
    if (byId != null) return 'Patient ID';
    if (byNationalId != null) return 'National ID';
    return null;
  }
}
