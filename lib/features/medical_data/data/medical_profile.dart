import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class MedicalProfile {
  final String ownerId;
  final UserRole ownerRole;
  final Map<String, double> factors;
  final List<String> diseases;
  final String createdByDoctorId;
  final String createdByDoctorName;
  final DateTime updatedAt;
  final String? backendResult;
  final double? backendLow;
  final double? backendMedium;
  final double? backendHigh;

  const MedicalProfile({
    required this.ownerId,
    required this.ownerRole,
    required this.factors,
    required this.diseases,
    required this.createdByDoctorId,
    required this.createdByDoctorName,
    required this.updatedAt,
    this.backendResult,
    this.backendLow,
    this.backendMedium,
    this.backendHigh,
  });

  MedicalProfile copyWith({
    String? ownerId,
    UserRole? ownerRole,
    Map<String, double>? factors,
    List<String>? diseases,
    String? createdByDoctorId,
    String? createdByDoctorName,
    DateTime? updatedAt,
    String? backendResult,
    double? backendLow,
    double? backendMedium,
    double? backendHigh,
  }) {
    return MedicalProfile(
      ownerId: ownerId ?? this.ownerId,
      ownerRole: ownerRole ?? this.ownerRole,
      factors: factors ?? this.factors,
      diseases: diseases ?? this.diseases,
      createdByDoctorId: createdByDoctorId ?? this.createdByDoctorId,
      createdByDoctorName: createdByDoctorName ?? this.createdByDoctorName,
      updatedAt: updatedAt ?? this.updatedAt,
      backendResult: backendResult ?? this.backendResult,
      backendLow: backendLow ?? this.backendLow,
      backendMedium: backendMedium ?? this.backendMedium,
      backendHigh: backendHigh ?? this.backendHigh,
    );
  }

  double get averageFactor {
    if (factors.isEmpty) return 0;
    final total = factors.values.fold<double>(0, (sum, value) => sum + value);
    return total / factors.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerRole': ownerRole.name,
      'factors': factors.map((key, value) => MapEntry(key, value)),
      'diseases': diseases,
      'createdByDoctorId': createdByDoctorId,
      'createdByDoctorName': createdByDoctorName,
      'updatedAt': updatedAt.toIso8601String(),
      'backendResult': backendResult,
      'backendLow': backendLow,
      'backendMedium': backendMedium,
      'backendHigh': backendHigh,
    };
  }

  static MedicalProfile? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final rawFactors = Map<String, dynamic>.from(map['factors'] as Map? ?? const {});
    return MedicalProfile(
      ownerId: (map['ownerId'] ?? '').toString(),
      ownerRole: UserRoleX.fromValue((map['ownerRole'] ?? 'patient').toString()),
      factors: rawFactors.map((key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0)),
      diseases: (map['diseases'] as List? ?? const []).map((e) => e.toString()).toList(),
      createdByDoctorId: (map['createdByDoctorId'] ?? '').toString(),
      createdByDoctorName: (map['createdByDoctorName'] ?? '').toString(),
      updatedAt: DateTime.tryParse((map['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      backendResult: (map['backendResult'] ?? '').toString().trim().isEmpty
          ? null
          : (map['backendResult'] ?? '').toString(),
      backendLow: _asDouble(map['backendLow']),
      backendMedium: _asDouble(map['backendMedium']),
      backendHigh: _asDouble(map['backendHigh']),
    );
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
