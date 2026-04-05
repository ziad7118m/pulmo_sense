import 'package:hive/hive.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/medical_profile.dart';

class MedicalDataStore {
  static const String boxName = 'medical_profiles';

  Future<Box> _box() => Hive.openBox(boxName);

  Future<MedicalProfile?> getProfile(String ownerId) async {
    final box = await _box();
    return MedicalProfile.fromMap(box.get(ownerId));
  }

  Future<void> upsert(MedicalProfile profile) async {
    final box = await _box();
    await box.put(profile.ownerId, profile.toMap());
  }

  Future<void> delete(String ownerId) async {
    final box = await _box();
    await box.delete(ownerId);
  }
}
