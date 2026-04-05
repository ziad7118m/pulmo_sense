import 'dart:io';

import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';

class EditProfileSeed {
  final UserProfile profile;
  final String firstName;
  final String lastName;
  final String gender;
  final String maritalStatus;
  final File? avatarFile;

  const EditProfileSeed({
    required this.profile,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.maritalStatus,
    required this.avatarFile,
  });

  static EditProfileSeed fromProfile({
    required UserProfile profile,
    required String displayName,
  }) {
    final parts = displayName
        .trim()
        .split(' ')
        .where((entry) => entry.trim().isNotEmpty)
        .toList();

    final avatarPath = profile.avatarPath.trim();
    final avatarFile =
        avatarPath.isNotEmpty && File(avatarPath).existsSync() ? File(avatarPath) : null;

    return EditProfileSeed(
      profile: profile,
      firstName: parts.isNotEmpty ? parts.first : '',
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      gender: (profile.gender).trim().isEmpty ? AppStrings.male : profile.gender,
      maritalStatus: (profile.marital).trim().isEmpty ? AppStrings.yes : profile.marital,
      avatarFile: avatarFile,
    );
  }
}
