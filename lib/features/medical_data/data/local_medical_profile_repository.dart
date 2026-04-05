import 'package:lung_diagnosis_app/features/medical_data/data/medical_data_store.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/mappers/medical_profile_mapper.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/repositories/medical_profile_repository.dart';

class LocalMedicalProfileRepository implements MedicalProfileRepository {
  final MedicalDataStore _store;

  LocalMedicalProfileRepository(this._store);

  @override
  Future<MedicalProfileRecord?> getProfile(String ownerId) async {
    final local = await _store.getProfile(ownerId);
    return local == null ? null : MedicalProfileMapper.fromLocal(local);
  }

  @override
  Future<void> saveProfile(MedicalProfileRecord profile) =>
      _store.upsert(MedicalProfileMapper.toLocal(profile));

  @override
  Future<void> deleteProfile(String ownerId) => _store.delete(ownerId);
}
