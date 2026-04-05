import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);
  Future<UserProfile> getOrCreate(String userId);
  Future<void> upsert(UserProfile profile);
  Future<void> deleteProfile(String userId);
  Future<String?> findUserIdByNationalId(String nationalId);
}
