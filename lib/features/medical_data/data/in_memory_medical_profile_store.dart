import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';

class InMemoryMedicalProfileStore {
  final Map<String, MedicalProfileRecord> _profiles = <String, MedicalProfileRecord>{};

  MedicalProfileRecord? getProfile(String ownerId) {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return null;

    final profile = _profiles[normalized];
    if (profile == null) return null;
    return _clone(profile);
  }

  Future<void> upsert(MedicalProfileRecord profile) async {
    final normalized = profile.ownerId.trim();
    if (normalized.isEmpty) return;
    _profiles[normalized] = _clone(profile);
  }

  Future<void> delete(String ownerId) async {
    final normalized = ownerId.trim();
    if (normalized.isEmpty) return;
    _profiles.remove(normalized);
  }

  MedicalProfileRecord _clone(MedicalProfileRecord profile) {
    return profile.copyWith(
      factors: Map<String, double>.from(profile.factors),
      diseases: List<String>.from(profile.diseases),
    );
  }
}
