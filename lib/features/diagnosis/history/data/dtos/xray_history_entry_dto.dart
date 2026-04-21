import 'package:intl/intl.dart';
import 'package:lung_diagnosis_app/core/config/app_config.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';

class XrayHistoryEntryDto {
  final DateTime createdAt;
  final String imageUrl;
  final String result;
  final double confidence;
  final double lungOpacity;
  final double normal;
  final double viralPneumonia;

  const XrayHistoryEntryDto({
    required this.createdAt,
    required this.imageUrl,
    required this.result,
    required this.confidence,
    required this.lungOpacity,
    required this.normal,
    required this.viralPneumonia,
  });

  factory XrayHistoryEntryDto.fromJson(Map<String, dynamic> json) {
    return XrayHistoryEntryDto(
      createdAt: _parseDateTime(json['createdAt'] ?? json['CreatedAt']),
      imageUrl: _normalizeImageUrl((json['imageUrl'] ?? json['ImageUrl'] ?? '').toString()),
      result: _normalizeLabel((json['result'] ?? json['Result'] ?? '').toString()),
      confidence: _normalizeProbability(_asDouble(json['confidence'] ?? json['Confidence'])),
      lungOpacity: _normalizeProbability(
        _asDouble(json['lungOpacity'] ?? json['LungOpacity']),
      ),
      normal: _normalizeProbability(_asDouble(json['normal'] ?? json['Normal'])),
      viralPneumonia: _normalizeProbability(
        _asDouble(json['viralPneumonia'] ?? json['ViralPneumonia']),
      ),
    );
  }

  Map<String, double> get classProbabilities => {
        'Lung Opacity': lungOpacity,
        'Normal': normal,
        'Viral Pneumonia': viralPneumonia,
      };

  DiagnosisItem toDiagnosisItem() {
    return DiagnosisItem(
      id: stableId,
      dateTime: DateFormat('d MMM yyyy • h:mm a').format(createdAt.toLocal()),
      diagnosis: result,
      percentage: (confidence * 100).clamp(0, 100).toDouble(),
      imagePath: imageUrl,
    );
  }

  DiagnosisResult toDiagnosisResult() {
    return DiagnosisResult(
      riskLevel: result,
      confidence: confidence,
      recommendation: _defaultRecommendation(result),
      classProbabilities: classProbabilities,
    );
  }

  String get stableId {
    final seed = '${createdAt.toUtc().toIso8601String()}|$imageUrl|$result';
    return 'xray_${createdAt.microsecondsSinceEpoch}_${_stableHexHash(seed)}';
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    final raw = (value ?? '').toString().trim();
    return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double _normalizeProbability(double value) {
    if (value > 1 && value <= 100) {
      return (value / 100).clamp(0.0, 1.0).toDouble();
    }
    return value.clamp(0.0, 1.0).toDouble();
  }

  static String _normalizeImageUrl(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return '';
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }

    final baseUrl = AppConfig.dev.baseUrl.replaceFirst(RegExp(r'/*$'), '');
    if (normalized.startsWith('/')) {
      return '$baseUrl$normalized';
    }
    return '$baseUrl/$normalized';
  }

  static String _normalizeLabel(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return '';

    final withSpaces = cleaned
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match.group(1)} ${match.group(2)}')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return withSpaces
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) {
          final lower = part.toLowerCase();
          return lower[0].toUpperCase() + lower.substring(1);
        })
        .join(' ');
  }

  static String _defaultRecommendation(String riskLevel) {
    final normalized = riskLevel.trim().toLowerCase();
    if (normalized.contains('normal')) {
      return 'The scan looks reassuring. Keep monitoring symptoms and review with a doctor if anything changes.';
    }
    if (normalized.contains('viral')) {
      return 'This result may need a doctor review, especially if you have fever, cough, or breathing symptoms.';
    }
    if (normalized.contains('opacity')) {
      return 'Please consult a doctor soon for a full assessment and the right treatment plan.';
    }
    return 'Follow medical guidance if symptoms persist.';
  }

  static String _stableHexHash(String input) {
    var hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
