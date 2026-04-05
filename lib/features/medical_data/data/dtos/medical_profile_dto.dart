import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class MedicalProfileDto {
  final String ownerId;
  final UserRole ownerRole;
  final Map<String, double> factors;
  final List<String> diseases;
  final String createdByDoctorId;
  final String createdByDoctorName;
  final DateTime updatedAt;

  const MedicalProfileDto({
    required this.ownerId,
    required this.ownerRole,
    required this.factors,
    required this.diseases,
    required this.createdByDoctorId,
    required this.createdByDoctorName,
    required this.updatedAt,
  });

  factory MedicalProfileDto.fromJson(Map<String, dynamic> json) {
    final rawFactors = Map<String, dynamic>.from(json['factors'] as Map? ?? const {});
    return MedicalProfileDto(
      ownerId: (json['ownerId'] ?? json['userId'] ?? json['patientId'] ?? '').toString(),
      ownerRole: UserRoleX.fromValue((json['ownerRole'] ?? 'patient').toString()),
      factors: rawFactors.map(
        (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0),
      ),
      diseases: (json['diseases'] as List? ?? const []).map((e) => e.toString()).toList(),
      createdByDoctorId: (json['createdByDoctorId'] ?? '').toString(),
      createdByDoctorName: (json['createdByDoctorName'] ?? '').toString(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'ownerRole': ownerRole.name,
      'factors': factors,
      'diseases': diseases,
      'createdByDoctorId': createdByDoctorId,
      'createdByDoctorName': createdByDoctorName,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
