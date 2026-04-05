import 'package:lung_diagnosis_app/features/profile/data/dtos/profile_dto.dart';
import 'package:lung_diagnosis_app/features/profile/data/local_profile.dart';
import 'package:lung_diagnosis_app/features/profile/domain/entities/user_profile.dart';

class ProfileMapper {
  const ProfileMapper._();

  static UserProfile toDomain(ProfileDto dto) {
    return UserProfile(
      userId: dto.userId,
      nationalId: dto.nationalId,
      address: dto.address,
      phone: dto.phone,
      birthDate: dto.birthDate,
      gender: dto.gender,
      marital: dto.maritalStatus,
      doctorLicense: dto.doctorLicense,
      avatarPath: dto.avatarPath,
      updatedAt: dto.updatedAt,
    );
  }

  static ProfileDto toDto(UserProfile profile) {
    return ProfileDto(
      userId: profile.userId,
      nationalId: profile.nationalId,
      address: profile.address,
      phone: profile.phone,
      birthDate: profile.birthDate,
      gender: profile.gender,
      maritalStatus: profile.marital,
      doctorLicense: profile.doctorLicense,
      avatarPath: profile.avatarPath,
      updatedAt: profile.updatedAt,
    );
  }

  static UserProfile fromLocal(LocalProfile profile) {
    return UserProfile(
      userId: profile.userId,
      nationalId: profile.nationalId,
      address: profile.address,
      phone: profile.phone,
      birthDate: profile.birthDate,
      gender: profile.gender,
      marital: profile.marital,
      doctorLicense: profile.doctorLicense,
      avatarPath: profile.avatarPath,
      updatedAt: profile.updatedAt,
    );
  }

  static LocalProfile toLocal(UserProfile profile) {
    return LocalProfile(
      userId: profile.userId,
      nationalId: profile.nationalId,
      address: profile.address,
      phone: profile.phone,
      birthDate: profile.birthDate,
      gender: profile.gender,
      marital: profile.marital,
      doctorLicense: profile.doctorLicense,
      avatarPath: profile.avatarPath,
      updatedAt: profile.updatedAt,
    );
  }
}
