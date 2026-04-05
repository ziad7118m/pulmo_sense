import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/profile_readonly_info_grid.dart';

List<ProfileReadonlyInfoItem> buildProfileInfoItems(UserProfile profile) {
  return [
    ProfileReadonlyInfoItem(
      label: AppStrings.nationalID,
      value: _displayValue(profile.nationalId),
    ),
    ProfileReadonlyInfoItem(
      label: AppStrings.place,
      value: _displayValue(profile.address),
    ),
    ProfileReadonlyInfoItem(
      label: AppStrings.phoneNum,
      value: _displayValue(profile.phone),
    ),
    ProfileReadonlyInfoItem(
      label: AppStrings.date,
      value: _displayValue(profile.birthDate),
    ),
    ProfileReadonlyInfoItem(
      label: AppStrings.gender,
      value: _displayValue(profile.gender),
    ),
    ProfileReadonlyInfoItem(
      label: AppStrings.marriage,
      value: _displayValue(profile.marital),
    ),
    if (profile.doctorLicense.trim().isNotEmpty)
      ProfileReadonlyInfoItem(
        label: AppStrings.licenceNumber,
        value: profile.doctorLicense,
      ),
  ];
}

String _displayValue(String value) {
  return value.trim().isEmpty ? '-' : value;
}
