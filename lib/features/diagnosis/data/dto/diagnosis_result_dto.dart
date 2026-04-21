class DiagnosisResultDto {
  final String riskLevel;
  final double confidence;
  final String recommendation;
  final Map<String, double> classProbabilities;

  const DiagnosisResultDto({
    required this.riskLevel,
    required this.confidence,
    required this.recommendation,
    required this.classProbabilities,
  });

  factory DiagnosisResultDto.fromJson(Map<String, dynamic> json) {
    final rawRiskLevel = _firstNonEmpty([
      json['riskLevel'],
      json['risk_level'],
      json['predictedClass'],
      json['PredictedClass'],
      json['result'],
      json['Result'],
      json['predicted_class'],
    ]);
    final riskLevel = _normalizeLabel(rawRiskLevel);

    final classProbabilities = _resolveClassProbabilities(json);
    final confidence = _resolveConfidence(
      json,
      rawRiskLevel: rawRiskLevel,
      classProbabilities: classProbabilities,
    );

    return DiagnosisResultDto(
      riskLevel: riskLevel,
      confidence: confidence,
      recommendation: _firstNonEmpty([
        json['recommendation'],
        json['advice'],
        json['note'],
      ], fallback: _defaultRecommendation(riskLevel)),
      classProbabilities: classProbabilities,
    );
  }

  Map<String, dynamic> toJson() => {
        'riskLevel': riskLevel,
        'confidence': confidence,
        'recommendation': recommendation,
        'classProbabilities': classProbabilities,
      };

  static String _firstNonEmpty(Iterable<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final normalized = (value ?? '').toString().trim();
      if (normalized.isNotEmpty) return normalized;
    }
    return fallback;
  }

  static double _resolveConfidence(
    Map<String, dynamic> json, {
    required String rawRiskLevel,
    required Map<String, double> classProbabilities,
  }) {
    final direct = _asDouble(json['confidence']);
    if (direct != null) return _normalizeConfidence(direct);

    final normalizedRiskLevel = _normalizeLabel(rawRiskLevel);
    if (normalizedRiskLevel.isNotEmpty) {
      final matched = classProbabilities[normalizedRiskLevel];
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

  static Map<String, double> _resolveClassProbabilities(Map<String, dynamic> json) {
    final resolved = <String, double>{};

    final nestedMap = _asMap(json['classProbabilities'] ?? json['ClassProbabilities']);
    if (nestedMap != null) {
      nestedMap.forEach((key, value) {
        final parsed = _asDouble(value);
        if (parsed == null) {
          return;
        }
        resolved[_normalizeLabel(key)] = _normalizeConfidence(parsed);
      });
    }

    const excludedNumericKeys = {
      'confidence',
      'createdat',
      'timestamp',
      'id',
      'userid',
      'patientid',
      'doctorid',
    };

    json.forEach((key, value) {
      final parsed = _asDouble(value);
      if (parsed == null) {
        return;
      }

      final normalizedKey = key.trim().toLowerCase();
      if (excludedNumericKeys.contains(normalizedKey)) {
        return;
      }

      if (nestedMap != null && (normalizedKey == 'high' || normalizedKey == 'medium' || normalizedKey == 'low')) {
        return;
      }

      if (normalizedKey == 'high' || normalizedKey == 'medium' || normalizedKey == 'low') {
        resolved[_normalizeLabel(key)] = _normalizeConfidence(parsed);
        return;
      }

      final originalKey = key.trim();
      final looksLikeProbabilityField = originalKey.contains('_') ||
          RegExp(r'[A-Z]').hasMatch(originalKey) ||
          originalKey.toLowerCase() == originalKey;

      if (!looksLikeProbabilityField) {
        return;
      }

      resolved[_normalizeLabel(key)] = _normalizeConfidence(parsed);
    });

    return Map.unmodifiable(resolved);
  }

  static String _normalizeLabel(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) {
      return '';
    }

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
      return 'The scan looks reassuring. Keep monitoring symptoms and review with a doctor if anything worsens.';
    }
    if (normalized.contains('viral') || normalized == 'medium') {
      return 'This result may need a doctor review, especially if you have fever, cough, or breathing symptoms.';
    }
    if (normalized.contains('opacity') || normalized == 'high') {
      return 'Please consult a doctor soon for a full assessment and the right treatment plan.';
    }
    return 'Follow medical guidance if symptoms persist.';
  }
}
