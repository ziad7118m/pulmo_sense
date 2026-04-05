import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class MedicalProfileRecord {
  final String ownerId;
  final UserRole ownerRole;
  final Map<String, double> factors;
  final List<String> diseases;
  final String createdByDoctorId;
  final String createdByDoctorName;
  final DateTime updatedAt;

  const MedicalProfileRecord({
    required this.ownerId,
    required this.ownerRole,
    required this.factors,
    required this.diseases,
    required this.createdByDoctorId,
    required this.createdByDoctorName,
    required this.updatedAt,
  });

  MedicalProfileRecord copyWith({
    String? ownerId,
    UserRole? ownerRole,
    Map<String, double>? factors,
    List<String>? diseases,
    String? createdByDoctorId,
    String? createdByDoctorName,
    DateTime? updatedAt,
  }) {
    return MedicalProfileRecord(
      ownerId: ownerId ?? this.ownerId,
      ownerRole: ownerRole ?? this.ownerRole,
      factors: factors ?? this.factors,
      diseases: diseases ?? this.diseases,
      createdByDoctorId: createdByDoctorId ?? this.createdByDoctorId,
      createdByDoctorName: createdByDoctorName ?? this.createdByDoctorName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get averageFactor {
    if (factors.isEmpty) return 0;
    final total = factors.values.fold<double>(0, (sum, value) => sum + value);
    return total / factors.length;
  }
}
