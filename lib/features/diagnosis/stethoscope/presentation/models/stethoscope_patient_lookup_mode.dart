enum StethoscopePatientLookupMode { account, nationalId }

extension StethoscopePatientLookupModeX on StethoscopePatientLookupMode {
  bool get isNationalId => this == StethoscopePatientLookupMode.nationalId;
  String get storageValue => isNationalId ? 'national' : 'account';
  String get inputLabel => isNationalId ? 'National ID' : 'Account ID';

  static StethoscopePatientLookupMode fromRaw(String? raw) {
    return raw == 'national'
        ? StethoscopePatientLookupMode.nationalId
        : StethoscopePatientLookupMode.account;
  }
}
