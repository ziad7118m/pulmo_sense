import 'package:lung_diagnosis_app/features/medical_data/domain/entities/medical_profile_record.dart';

class LungRiskAnalyzer {
  const LungRiskAnalyzer._();

  static Future<double> analyzeOverallRisk(MedicalProfileRecord? medical) async {
    return resolveOverallRisk(medical);
  }

  static double resolveOverallRisk(MedicalProfileRecord? medical) {
    final backend = backendHighPercent(medical);
    if (backend != null) {
      return backend;
    }
    return localFallback(medical);
  }

  static double? backendHighPercent(MedicalProfileRecord? medical) {
    final value = medical?.backendHigh;
    if (value == null) return null;
    return normalizePercent(value);
  }

  static double? backendLowPercent(MedicalProfileRecord? medical) {
    final value = medical?.backendLow;
    if (value == null) return null;
    return normalizePercent(value);
  }

  static double? backendMediumPercent(MedicalProfileRecord? medical) {
    final value = medical?.backendMedium;
    if (value == null) return null;
    return normalizePercent(value);
  }

  static double normalizePercent(double value) {
    if (value <= 1) {
      return (value * 100).clamp(0, 100).toDouble();
    }
    return value.clamp(0, 100).toDouble();
  }

  static double localFallback(MedicalProfileRecord? medical) {
    final factors = medical?.factors.values.toList() ?? const <double>[];
    if (factors.isEmpty) return 0.0;
    return factors.reduce((a, b) => a + b) / factors.length;
  }
}
