import 'package:lung_diagnosis_app/features/medical_data/data/dtos/medical_profile_dto.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/medical_profile.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';

class MedicalProfileMapper {
  const MedicalProfileMapper._();

  static MedicalProfileRecord fromDto(MedicalProfileDto dto) {
    return MedicalProfileRecord(
      ownerId: dto.ownerId,
      ownerRole: dto.ownerRole,
      factors: dto.factors,
      diseases: dto.diseases,
      createdByDoctorId: dto.createdByDoctorId,
      createdByDoctorName: dto.createdByDoctorName,
      updatedAt: dto.updatedAt,
    );
  }

  static MedicalProfileDto toDto(MedicalProfileRecord profile) {
    return MedicalProfileDto(
      ownerId: profile.ownerId,
      ownerRole: profile.ownerRole,
      factors: profile.factors,
      diseases: profile.diseases,
      createdByDoctorId: profile.createdByDoctorId,
      createdByDoctorName: profile.createdByDoctorName,
      updatedAt: profile.updatedAt,
    );
  }

  static MedicalProfileRecord fromLocal(MedicalProfile local) {
    return MedicalProfileRecord(
      ownerId: local.ownerId,
      ownerRole: local.ownerRole,
      factors: local.factors,
      diseases: local.diseases,
      createdByDoctorId: local.createdByDoctorId,
      createdByDoctorName: local.createdByDoctorName,
      updatedAt: local.updatedAt,
    );
  }

  static MedicalProfile toLocal(MedicalProfileRecord profile) {
    return MedicalProfile(
      ownerId: profile.ownerId,
      ownerRole: profile.ownerRole,
      factors: profile.factors,
      diseases: profile.diseases,
      createdByDoctorId: profile.createdByDoctorId,
      createdByDoctorName: profile.createdByDoctorName,
      updatedAt: profile.updatedAt,
    );
  }
}
