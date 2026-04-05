import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';

class ProfileScreenViewData {
  final AuthUser user;
  final UserProfile profile;
  final bool isLoading;

  const ProfileScreenViewData({
    required this.user,
    required this.profile,
    required this.isLoading,
  });
}
