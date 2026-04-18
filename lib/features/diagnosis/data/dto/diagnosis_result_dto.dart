class DiagnosisResultDto {
  final String riskLevel;
  final double confidence;
  final String recommendation;

  const DiagnosisResultDto({
    required this.riskLevel,
    required this.confidence,
    required this.recommendation,
  });

  factory DiagnosisResultDto.fromJson(Map<String, dynamic> json) {
    final riskLevel = _firstNonEmpty([
      json['riskLevel'],
      json['risk_level'],
      json['predictedClass'],
      json['PredictedClass'],
      json['result'],
      json['Result'],
      json['predicted_class'],
    ]);

    final confidence = _resolveConfidence(json, riskLevel);

    return DiagnosisResultDto(
      riskLevel: riskLevel,
      confidence: confidence,
      recommendation: _firstNonEmpty([
        json['recommendation'],
        json['advice'],
        json['note'],
      ], fallback: _defaultRecommendation(riskLevel)),
    );
  }

  Map<String, dynamic> toJson() => {
    'riskLevel': riskLevel,
    'confidence': confidence,
    'recommendation': recommendation,
  };

  static String _firstNonEmpty(Iterable<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final normalized = (value ?? '').toString().trim();
      if (normalized.isNotEmpty) return normalized;
    }
    return fallback;
  }

  static double _resolveConfidence(Map<String, dynamic> json, String riskLevel) {
    final direct = _asDouble(json['confidence']);
    if (direct != null) return _normalizeConfidence(direct);

    final classProbabilities = _asMap(json['classProbabilities'] ?? json['ClassProbabilities']);
    if (classProbabilities != null && riskLevel.trim().isNotEmpty) {
      final matched = _asDouble(
        classProbabilities[riskLevel] ??
            classProbabilities[riskLevel.toLowerCase()] ??
            classProbabilities[riskLevel.replaceAll(' ', '')],
      );
      if (matched != null) return _normalizeConfidence(matched);
    }

    final high = _asDouble(json['high'] ?? json['High']);
    if (high != null) return _normalizeConfidence(high);

    final medium = _asDouble(json['medium'] ?? json['Medium']);
    if (medium != null) return _normalizeConfidence(medium);

    final low = _asDouble(json['low'] ?? json['Low']);
    if (low != null) return _normalizeConfidence(low);

    return 0.0;
  }

  static double _normalizeConfidence(double value) {
    if (value > 1 && value <= 100) return value / 100;
    return value.clamp(0.0, 1.0).toDouble();
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _defaultRecommendation(String riskLevel) {
    final normalized = riskLevel.trim().toLowerCase();
    if (normalized.contains('normal') || normalized == 'low') {
      return 'Keep following healthy habits and review with a doctor if symptoms appear.';
    }
    if (normalized.contains('viral') || normalized == 'medium') {
      return 'Please review the result with a doctor and monitor your symptoms closely.';
    }
    if (normalized.contains('opacity') || normalized == 'high') {
      return 'Please consult a doctor as soon as possible for a full assessment.';
    }
    return 'Follow medical guidance if symptoms persist.';
  }
}
