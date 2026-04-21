import 'package:lung_diagnosis_app/features/medical_data/data/dtos/lung_risk_history_entry_dto.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class MedicalProfileDto {
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

  const MedicalProfileDto({
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

  static const Map<String, List<String>> _factorAliases = {
    'Obesity': ['obesity', 'Obesity'],
    'Coughing of blood': ['coughingOfBlood', 'coughing_of_blood', 'CoughingOfBlood'],
    'Alcohol use': ['alcoholUse', 'alcohol_use', 'AlcoholUse'],
    'Dust allergy': ['dustAllergy', 'dust_allergy', 'DustAllergy'],
    'Balanced diet': ['balancedDiet', 'balanced_diet', 'BalancedDiet'],
    'Passive smoker': ['passiveSmoker', 'passive_smoker', 'PassiveSmoker'],
    'Genetic risk': ['geneticRisk', 'genetic_risk', 'GeneticRisk'],
    'Occupational hazards': [
      'occupationalHazards',
      'occupational_hazards',
      'OccupationalHazards',
    ],
    'Chest pain': ['chestPain', 'chest_pain', 'ChestPain'],
    'Air pollution': ['airPollution', 'air_pollution', 'AirPollution'],
  };

  factory MedicalProfileDto.fromJson(Map<String, dynamic> json) {
    final rawFactors = _extractFactors(json);
    return MedicalProfileDto(
      ownerId: (json['ownerId'] ?? json['userId'] ?? json['patientId'] ?? json['id'] ?? '')
          .toString(),
      ownerRole: UserRoleX.fromValue(
        (json['ownerRole'] ?? json['role'] ?? 'patient').toString(),
      ),
      factors: rawFactors,
      diseases: _extractDiseases(json),
      createdByDoctorId:
          (json['createdByDoctorId'] ?? json['doctorId'] ?? json['createdBy'] ?? '')
              .toString(),
      createdByDoctorName:
          (json['createdByDoctorName'] ?? json['doctorName'] ?? json['createdByName'] ?? '')
              .toString(),
      updatedAt: DateTime.tryParse(
            (json['updatedAt'] ?? json['lastUpdatedAt'] ?? json['createdAt'] ?? '')
                .toString(),
          ) ??
          DateTime.now(),
      backendResult: (json['backendResult'] ?? json['result'] ?? json['Result'] ?? '')
              .toString()
              .trim()
              .isEmpty
          ? null
          : (json['backendResult'] ?? json['result'] ?? json['Result']).toString(),
      backendLow: _extractDouble(json, const ['backendLow', 'low', 'Low']),
      backendMedium: _extractDouble(json, const ['backendMedium', 'medium', 'Medium']),
      backendHigh: _extractDouble(json, const ['backendHigh', 'high', 'High']),
    );
  }

  factory MedicalProfileDto.fromRiskHistory(
    LungRiskHistoryEntryDto entry, {
    required String ownerId,
    required UserRole ownerRole,
  }) {
    return MedicalProfileDto(
      ownerId: ownerId,
      ownerRole: ownerRole,
      factors: <String, double>{
        'Obesity': entry.obesity * 10.0,
        'Coughing of blood': entry.coughingOfBlood * 10.0,
        'Alcohol use': entry.alcoholUse * 10.0,
        'Dust allergy': entry.dustAllergy * 10.0,
        'Balanced diet': entry.balancedDiet * 10.0,
        'Passive smoker': entry.passiveSmoker * 10.0,
        'Genetic risk': entry.geneticRisk * 10.0,
        'Occupational hazards': entry.occupationalHazards * 10.0,
        'Chest pain': entry.chestPain * 10.0,
        'Air pollution': entry.airPollution * 10.0,
      },
      diseases: const <String>[],
      createdByDoctorId: '',
      createdByDoctorName: '',
      updatedAt: entry.createdAt,
      backendResult: entry.result,
      backendLow: entry.low,
      backendMedium: entry.medium,
      backendHigh: entry.high,
    );
  }

  MedicalProfileDto copyWith({
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
    return MedicalProfileDto(
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

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'ownerId': ownerId,
      'userId': ownerId,
      'patientId': ownerId,
      'ownerRole': ownerRole.name,
      'role': ownerRole.name,
      'factors': factors,
      'diseases': diseases,
      'createdByDoctorId': createdByDoctorId,
      'doctorId': createdByDoctorId,
      'createdByDoctorName': createdByDoctorName,
      'doctorName': createdByDoctorName,
      'updatedAt': updatedAt.toIso8601String(),
      'backendResult': backendResult,
      'backendLow': backendLow,
      'backendMedium': backendMedium,
      'backendHigh': backendHigh,
    };

    for (final entry in _factorAliases.entries) {
      final value = factors[entry.key] ?? 0;
      for (final alias in entry.value) {
        payload[alias] = value;
      }
    }

    return payload;
  }

  Map<String, dynamic> toLungRiskRequestJson() {
    return <String, dynamic>{
      'obesity': _scaledFactor('Obesity'),
      'coughingOfBlood': _scaledFactor('Coughing of blood'),
      'alcoholUse': _scaledFactor('Alcohol use'),
      'dustAllergy': _scaledFactor('Dust allergy'),
      'passiveSmoker': _scaledFactor('Passive smoker'),
      'balancedDiet': _scaledFactor('Balanced diet'),
      'geneticRisk': _scaledFactor('Genetic risk'),
      'occupationalHazards': _scaledFactor('Occupational hazards'),
      'chestPain': _scaledFactor('Chest pain'),
      'airPollution': _scaledFactor('Air pollution'),
    };
  }

  int _scaledFactor(String key) {
    final raw = factors[key] ?? 0;
    return (raw / 10).round().clamp(0, 10);
  }

  static Map<String, double> _extractFactors(Map<String, dynamic> json) {
    final nestedFactors = json['factors'];
    if (nestedFactors is Map) {
      return Map<String, dynamic>.from(nestedFactors).map(
        (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0),
      );
    }

    final resolved = <String, double>{};
    for (final entry in _factorAliases.entries) {
      resolved[entry.key] = _extractDouble(json, entry.value) ?? 0;
    }
    return resolved;
  }

  static List<String> _extractDiseases(Map<String, dynamic> json) {
    final direct = json['diseases'];
    if (direct is List) {
      return direct.map((e) => e.toString()).toList(growable: false);
    }

    final medicalHistory = json['medicalHistory'];
    if (medicalHistory is List) {
      return medicalHistory.map((e) => e.toString()).toList(growable: false);
    }

    return const <String>[];
  }

  static double? _extractDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}
