import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/data/dto/diagnosis_result_dto.dart';

class AudioHistoryEntryDto {
  final DateTime analyzedAt;
  final String audioUrl;
  final String result;
  final double confidence;
  final String? supportLabel;
  final double? riskScore;
  final double? covidProbability;
  final double? normalProbability;
  final String? clinicalUse;
  final String? patientId;

  const AudioHistoryEntryDto({
    required this.analyzedAt,
    required this.audioUrl,
    required this.result,
    required this.confidence,
    this.supportLabel,
    this.riskScore,
    this.covidProbability,
    this.normalProbability,
    this.clinicalUse,
    this.patientId,
  });

  factory AudioHistoryEntryDto.fromJson(Map<String, dynamic> json) {
    final diagnosisDto = DiagnosisResultDto.fromJson(json);
    final fallbackDate = DateTime.now();

    return AudioHistoryEntryDto(
      analyzedAt: DateTime.tryParse(
            (json['dateTime'] ?? json['analyzedAt'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          fallbackDate,
      audioUrl: (json['audioUrl'] ?? json['audioURL'] ?? json['audio_url'] ?? '').toString(),
      result: diagnosisDto.riskLevel,
      confidence: diagnosisDto.confidence,
      supportLabel: _nullableString(json['supportLabel'] ?? json['support_label']),
      riskScore: _toDouble(json['riskScore'] ?? json['risk_score']),
      covidProbability: _toDouble(json['covidProbability'] ?? json['covid_probability']),
      normalProbability: _toDouble(json['normalProbability'] ?? json['normal_probability']),
      clinicalUse: _nullableString(json['clinicalUse'] ?? json['clinical_use']),
      patientId: _nullableString(json['patientId'] ?? json['patient_id']),
    );
  }

  DiagnosisItem toDiagnosisItem() {
    return DiagnosisItem(
      id: legacyDiagnosisItemId(
        dateTime: analyzedAt.toIso8601String(),
        diagnosis: result,
        percentage: confidence,
        audioPath: audioUrl,
      ),
      dateTime: analyzedAt.toIso8601String(),
      diagnosis: result,
      percentage: confidence,
      audioPath: audioUrl,
      audioSourceType: AudioSourceType.uploaded,
      targetPatientId: patientId,
    );
  }

  DiagnosisResult toDiagnosisResult() {
    final map = <String, dynamic>{
      'result': result,
      'confidence': confidence,
      'audioUrl': audioUrl,
      if (supportLabel != null) 'supportLabel': supportLabel,
      if (riskScore != null) 'riskScore': riskScore,
      if (covidProbability != null) 'covidProbability': covidProbability,
      if (normalProbability != null) 'normalProbability': normalProbability,
      if (clinicalUse != null) 'clinicalUse': clinicalUse,
      if (patientId != null) 'patientId': patientId,
      'dateTime': analyzedAt.toIso8601String(),
    };
    final dto = DiagnosisResultDto.fromJson(map);
    return DiagnosisResult(
      riskLevel: dto.riskLevel,
      confidence: dto.confidence,
      recommendation: dto.recommendation,
      classProbabilities: dto.classProbabilities,
    );
  }

  static String? _nullableString(dynamic value) {
    final normalized = (value ?? '').toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
