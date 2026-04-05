import 'package:lung_diagnosis_app/features/medical_data/data/medical_data_store.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/medical_profile.dart';

class MedicalProfileLocalDataSource {
  final MedicalDataStore _store;

  const MedicalProfileLocalDataSource(this._store);

  Future<MedicalProfile?> getProfile(String ownerId) => _store.getProfile(ownerId);

  Future<void> saveProfile(MedicalProfile profile) => _store.upsert(profile);

  Future<void> deleteProfile(String ownerId) => _store.delete(ownerId);
}
