import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';

abstract class MedicalProfileRepository {
  Future<MedicalProfileRecord?> getProfile(String ownerId);
  Future<void> saveProfile(MedicalProfileRecord profile);
  Future<void> deleteProfile(String ownerId);
}
