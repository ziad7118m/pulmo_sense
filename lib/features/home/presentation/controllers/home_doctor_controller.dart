import 'dart:io';

import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/features/home/presentation/models/home_doctor_view_data.dart';

class HomeDoctorController {
  const HomeDoctorController();

  HomeDoctorViewData build({
    required String? currentUserName,
    required String? avatarPath,
    required int notificationCount,
  }) {
    return HomeDoctorViewData(
      doctorName: _resolveDoctorName(currentUserName),
      profileImagePath: _resolveProfileImagePath(avatarPath),
      notificationCount: notificationCount,
    );
  }

  String _resolveDoctorName(String? currentUserName) {
    final normalizedName = (currentUserName ?? '').trim();
    if (normalizedName.isEmpty) return AppStrings.drName;
    return normalizedName;
  }

  String _resolveProfileImagePath(String? avatarPath) {
    final normalizedPath = (avatarPath ?? '').trim();
    if (normalizedPath.isEmpty) return '';
    return File(normalizedPath).existsSync() ? normalizedPath : '';
  }
}
