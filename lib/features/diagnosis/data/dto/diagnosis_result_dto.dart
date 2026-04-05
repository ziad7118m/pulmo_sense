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
    final rawConfidence = json['confidence'];

    double conf;
    if (rawConfidence is num) {
      conf = rawConfidence.toDouble();
    } else if (rawConfidence is String) {
      conf = double.tryParse(rawConfidence) ?? 0.0;
    } else {
      conf = 0.0;
    }

    return DiagnosisResultDto(
      riskLevel: (json['riskLevel'] ?? json['risk_level'] ?? '').toString(),
      confidence: conf,
      recommendation:
      (json['recommendation'] ?? json['advice'] ?? json['note'] ?? '')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'riskLevel': riskLevel,
    'confidence': confidence,
    'recommendation': recommendation,
  };
}
