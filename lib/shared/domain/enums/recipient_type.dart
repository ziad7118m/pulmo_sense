enum RecipientType { self, patient }

extension RecipientTypeX on RecipientType {
  String get apiValue => name;

  static RecipientType fromValue(String raw) {
    return RecipientType.values.firstWhere(
      (value) => value.name == raw.trim().toLowerCase(),
      orElse: () => RecipientType.self,
    );
  }
}
