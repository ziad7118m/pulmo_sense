class DiagnosisResult {
  final String riskLevel; // e.g. Low / Medium / High
  final double confidence; // 0..1
  final String recommendation;

  const DiagnosisResult({
    required this.riskLevel,
    required this.confidence,
    required this.recommendation,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      riskLevel: (json['riskLevel'] ?? '').toString(),
      confidence: _toDouble(json['confidence']),
      recommendation: (json['recommendation'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'riskLevel': riskLevel,
    'confidence': confidence,
    'recommendation': recommendation,
  };

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}
