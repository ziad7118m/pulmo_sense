class LungRiskHistoryEntryDto {
  final DateTime createdAt;
  final int obesity;
  final int coughingOfBlood;
  final int alcoholUse;
  final int dustAllergy;
  final int passiveSmoker;
  final int balancedDiet;
  final int geneticRisk;
  final int occupationalHazards;
  final int chestPain;
  final int airPollution;
  final String result;
  final double low;
  final double medium;
  final double high;

  const LungRiskHistoryEntryDto({
    required this.createdAt,
    required this.obesity,
    required this.coughingOfBlood,
    required this.alcoholUse,
    required this.dustAllergy,
    required this.passiveSmoker,
    required this.balancedDiet,
    required this.geneticRisk,
    required this.occupationalHazards,
    required this.chestPain,
    required this.airPollution,
    required this.result,
    required this.low,
    required this.medium,
    required this.high,
  });

  factory LungRiskHistoryEntryDto.fromJson(Map<String, dynamic> json) {
    return LungRiskHistoryEntryDto(
      createdAt: _parseDateTime(json['createdAt'] ?? json['CreatedAt']),
      obesity: _asInt(json['obesity'] ?? json['Obesity']),
      coughingOfBlood: _asInt(json['coughingOfBlood'] ?? json['CoughingOfBlood']),
      alcoholUse: _asInt(json['alcoholUse'] ?? json['AlcoholUse']),
      dustAllergy: _asInt(json['dustAllergy'] ?? json['DustAllergy']),
      passiveSmoker: _asInt(json['passiveSmoker'] ?? json['PassiveSmoker']),
      balancedDiet: _asInt(json['balancedDiet'] ?? json['BalancedDiet']),
      geneticRisk: _asInt(json['geneticRisk'] ?? json['GeneticRisk']),
      occupationalHazards: _asInt(
        json['occupationalHazards'] ?? json['OccupationalHazards'],
      ),
      chestPain: _asInt(json['chestPain'] ?? json['ChestPain']),
      airPollution: _asInt(json['airPollution'] ?? json['AirPollution']),
      result: (json['result'] ?? json['Result'] ?? 'Unknown').toString(),
      low: _asDouble(json['low'] ?? json['Low']),
      medium: _asDouble(json['medium'] ?? json['Medium']),
      high: _asDouble(json['high'] ?? json['High']),
    );
  }

  List<MapEntry<String, int>> get factors => [
        MapEntry('Obesity', obesity),
        MapEntry('Coughing of blood', coughingOfBlood),
        MapEntry('Alcohol use', alcoholUse),
        MapEntry('Dust allergy', dustAllergy),
        MapEntry('Passive smoker', passiveSmoker),
        MapEntry('Balanced diet', balancedDiet),
        MapEntry('Genetic risk', geneticRisk),
        MapEntry('Occupational hazards', occupationalHazards),
        MapEntry('Chest pain', chestPain),
        MapEntry('Air pollution', airPollution),
      ];

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
