import 'package:lung_diagnosis_app/core/utils/date_text_formatter.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_info_row.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/admin_user_details_data.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

Future<AdminUserDetailsData> loadAdminUserDetailsData({
  required AuthUser user,
  required ProfileRepository profileRepository,
  required ArticleController articleController,
}) async {
  final profile = await profileRepository.getOrCreate(user.id);
  var articleCount = 0;
  if (user.role.isDoctor) {
    articleCount = (await articleController.byAuthor(user.id)).length;
  }

  return AdminUserDetailsData(
    profile: profile,
    articleCount: articleCount,
    accountRows: buildAdminAccountRows(user),
    profileRows: buildAdminProfileRows(user, profile),
    insightRows: buildAdminInsightRows(user, profile, articleCount),
  );
}

List<AdminInfoRow> buildAdminAccountRows(AuthUser user) {
  return [
    AdminInfoRow(label: 'ID', value: user.id),
    AdminInfoRow(label: 'Email', value: user.email),
    AdminInfoRow(label: 'Name', value: user.displayName.isEmpty ? '-' : user.displayName),
    AdminInfoRow(label: 'Role', value: user.role.displayName),
    AdminInfoRow(label: 'Status', value: user.status.displayName),
    AdminInfoRow(label: 'Created', value: formatIsoDateOnly(user.createdAt)),
  ];
}

List<AdminInfoRow> buildAdminProfileRows(AuthUser user, UserProfile profile) {
  return [
    AdminInfoRow(label: 'National ID', value: profile.nationalId.isEmpty ? '-' : profile.nationalId),
    AdminInfoRow(label: 'Address', value: profile.address.isEmpty ? '-' : profile.address),
    AdminInfoRow(label: 'Phone', value: profile.phone.isEmpty ? '-' : profile.phone),
    AdminInfoRow(label: 'Birth date', value: profile.birthDate.isEmpty ? '-' : profile.birthDate),
    AdminInfoRow(label: 'Gender', value: profile.gender.isEmpty ? '-' : profile.gender),
    AdminInfoRow(label: 'Marital', value: profile.marital.isEmpty ? '-' : profile.marital),
    if (user.role.isDoctor)
      AdminInfoRow(label: 'License', value: profile.doctorLicense.isEmpty ? '-' : profile.doctorLicense),
  ];
}

List<AdminInfoRow> buildAdminInsightRows(AuthUser user, UserProfile profile, int articleCount) {
  final completion = calculateAdminProfileCompletion(
    profile,
    includeLicense: user.role.isDoctor,
  );

  return [
    AdminInfoRow(label: 'Profile ready', value: '$completion%'),
    AdminInfoRow(label: 'Avatar', value: profile.avatarPath.trim().isEmpty ? 'Missing' : 'Uploaded'),
    AdminInfoRow(label: 'Doctor content', value: user.role.isDoctor ? '$articleCount article(s)' : 'Not applicable'),
    AdminInfoRow(
      label: 'Suggested next step',
      value: buildAdminNextStep(user, profile, articleCount),
    ),
  ];
}

int calculateAdminProfileCompletion(
  UserProfile profile, {
  required bool includeLicense,
}) {
  final values = <String>[
    profile.nationalId,
    profile.address,
    profile.phone,
    profile.birthDate,
    profile.gender,
    profile.marital,
    profile.avatarPath,
    if (includeLicense) profile.doctorLicense,
  ];
  final filled = values.where((value) => value.trim().isNotEmpty).length;
  if (values.isEmpty) return 0;
  return ((filled / values.length) * 100).round();
}

String buildAdminNextStep(AuthUser user, UserProfile profile, int articleCount) {
  if (user.status.isPending) {
    return user.role.isDoctor
        ? 'Review the doctor request and pick the final approved role.'
        : 'Approve or reject the new patient request.';
  }
  if (user.status.isDisabled) {
    return 'Enable this account only when access should be restored.';
  }
  if (user.status.isRejected) {
    return 'Approve again only if the registration should re-enter the system.';
  }
  if (profile.nationalId.trim().isEmpty || profile.phone.trim().isEmpty) {
    return 'Profile is active, but still missing important contact details.';
  }
  if (user.role.isDoctor && articleCount == 0) {
    return 'Doctor is active with no published articles yet.';
  }
  return 'Account looks healthy and ready for normal usage.';
}
