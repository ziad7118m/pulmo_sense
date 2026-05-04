class DiagnosisResultDto {
  final String riskLevel;
  final double confidence;
  final String recommendation;
  final Map<String, double> classProbabilities;
  final String? audioUrl;
  final String? patientId;
  final DateTime? dateTime;

  const DiagnosisResultDto({
    required this.riskLevel,
    required this.confidence,
    required this.recommendation,
    required this.classProbabilities,
    this.audioUrl,
    this.patientId,
    this.dateTime,
  });

  factory DiagnosisResultDto.fromJson(Map<String, dynamic> json) {
    final rawRiskLevel = _firstNonEmpty([
      // Cough response
      json['supportLabel'],
      json['support_label'],
      // Stethoscope response
      json['result'],
      json['Result'],
      // Old / generic responses
      json['riskLevel'],
      json['risk_level'],
      json['predictedClass'],
      json['PredictedClass'],
      json['predicted_class'],
    ]);
    final riskLevel = _normalizeLabel(rawRiskLevel);

    final classProbabilities = _resolveClassProbabilities(json);
    final confidence = _resolveConfidence(
      json,
      rawRiskLevel: rawRiskLevel,
      classProbabilities: classProbabilities,
    );

    final clinicalUse = _firstNonEmpty([
      json['clinicalUse'],
      json['clinical_use'],
    ]);

    return DiagnosisResultDto(
      riskLevel: riskLevel,
      confidence: confidence,
      recommendation: _firstNonEmpty([
        json['recommendation'],
        json['advice'],
        json['note'],
        clinicalUse.isEmpty ? null : _clinicalUseMessage(clinicalUse),
      ], fallback: _defaultRecommendation(riskLevel)),
      classProbabilities: classProbabilities,
      audioUrl: _nullableString(json['audioUrl'] ?? json['audioURL'] ?? json['audio_url']),
      patientId: _nullableString(json['patientId'] ?? json['patient_id']),
      dateTime: _parseDateTime(json['dateTime'] ?? json['analyzedAt'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'riskLevel': riskLevel,
        'confidence': confidence,
        'recommendation': recommendation,
        'classProbabilities': classProbabilities,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (patientId != null) 'patientId': patientId,
        if (dateTime != null) 'dateTime': dateTime!.toIso8601String(),
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

    // Cough API sends riskScore instead of confidence.
    final riskScore = _asDouble(json['riskScore'] ?? json['risk_score']);
    if (riskScore != null) return _normalizeConfidence(riskScore);

    final normalizedRiskLevel = _normalizeLabel(rawRiskLevel);
    if (normalizedRiskLevel.isNotEmpty) {
      final matched = classProbabilities[normalizedRiskLevel];
      if (matched != null) return _normalizeConfidence(matched);
    }

    final normal = _asDouble(json['normalProbability'] ?? json['normal_probability']);
    final covid = _asDouble(json['covidProbability'] ?? json['covid_probability']);
    if (normal != null || covid != null) {
      return _normalizeConfidence([normal ?? 0.0, covid ?? 0.0].reduce((a, b) => a > b ? a : b));
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

    final normalProbability = _asDouble(json['normalProbability'] ?? json['normal_probability']);
    if (normalProbability != null) {
      resolved['Normal'] = _normalizeConfidence(normalProbability);
    }

    final covidProbability = _asDouble(json['covidProbability'] ?? json['covid_probability']);
    if (covidProbability != null) {
      resolved['Covid'] = _normalizeConfidence(covidProbability);
    }

    final nestedMap = _asMap(json['classProbabilities'] ?? json['ClassProbabilities']);
    if (nestedMap != null) {
      nestedMap.forEach((key, value) {
        final parsed = _asDouble(value);
        if (parsed == null) return;
        resolved[_normalizeLabel(key.toString())] = _normalizeConfidence(parsed);
      });
    }

    const excludedNumericKeys = {
      'confidence',
      'riskscore',
      'createdat',
      'datetime',
      'analyzedat',
      'timestamp',
      'id',
      'userid',
      'patientid',
      'doctorid',
      'normalprobability',
      'covidprobability',
    };

    json.forEach((key, value) {
      final parsed = _asDouble(value);
      if (parsed == null) return;

      final normalizedKey = key.toString().trim().toLowerCase();
      if (excludedNumericKeys.contains(normalizedKey)) return;

      if (normalizedKey == 'high' || normalizedKey == 'medium' || normalizedKey == 'low') {
        resolved[_normalizeLabel(key.toString())] = _normalizeConfidence(parsed);
      }
    });

    return Map.unmodifiable(resolved);
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

  static String? _nullableString(dynamic value) {
    final normalized = (value ?? '').toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  static DateTime? _parseDateTime(dynamic value) {
    final normalized = _nullableString(value);
    if (normalized == null) return null;
    return DateTime.tryParse(normalized);
  }

  static String _clinicalUseMessage(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'physician_decision_support') {
      return 'Use this result as physician decision support, not as a standalone diagnosis.';
    }
    return _normalizeLabel(value);
  }

  static String _defaultRecommendation(String riskLevel) {
    final normalized = riskLevel.trim().toLowerCase();
    if (normalized.contains('normal') || normalized == 'low' || normalized.contains('low covid')) {
      return 'The result looks reassuring. Keep monitoring symptoms and review with a doctor if anything worsens.';
    }
    if (normalized.contains('viral') || normalized == 'medium' || normalized.contains('covid')) {
      return 'This result may need a doctor review, especially if you have fever, cough, or breathing symptoms.';
    }
    if (normalized.contains('opacity') || normalized == 'high' || normalized.contains('abnormal')) {
      return 'Please consult a doctor soon for a full assessment and the right treatment plan.';
    }
    return 'Follow medical guidance if symptoms persist.';
  }
}
