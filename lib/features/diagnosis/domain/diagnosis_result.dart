class DiagnosisProbability {
  final String label;
  final double value;

  const DiagnosisProbability({
    required this.label,
    required this.value,
  });
}

class DiagnosisResult {
  final String riskLevel; // e.g. Low / Medium / High or diagnosis label
  final double confidence; // 0..1
  final String recommendation;
  final Map<String, double> classProbabilities;

  const DiagnosisResult({
    required this.riskLevel,
    required this.confidence,
    required this.recommendation,
    this.classProbabilities = const {},
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    final rawProbabilities = json['classProbabilities'];
    return DiagnosisResult(
      riskLevel: (json['riskLevel'] ?? '').toString(),
      confidence: _normalizeConfidence(_toDouble(json['confidence'])),
      recommendation: (json['recommendation'] ?? '').toString(),
      classProbabilities: _toProbabilityMap(rawProbabilities),
    );
  }

  Map<String, dynamic> toJson() => {
        'riskLevel': riskLevel,
        'confidence': confidence,
        'recommendation': recommendation,
        'classProbabilities': classProbabilities,
      };

  bool get hasProbabilityBreakdown => classProbabilities.isNotEmpty;

  List<DiagnosisProbability> get sortedProbabilities {
    final items = classProbabilities.entries
        .map(
          (entry) => DiagnosisProbability(
            label: entry.key,
            value: entry.value.clamp(0.0, 1.0).toDouble(),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    return items;
  }

  static Map<String, double> _toProbabilityMap(dynamic value) {
    if (value is! Map) {
      return const {};
    }

    final map = <String, double>{};
    value.forEach((key, rawValue) {
      final normalizedKey = key.toString().trim();
      if (normalizedKey.isEmpty) {
        return;
      }

      final parsed = _toDouble(rawValue);
      map[normalizedKey] = _normalizeConfidence(parsed);
    });

    return Map.unmodifiable(map);
  }

  static double _normalizeConfidence(double value) {
    if (value > 1 && value <= 100) return value / 100;
    return value.clamp(0.0, 1.0).toDouble();
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}
