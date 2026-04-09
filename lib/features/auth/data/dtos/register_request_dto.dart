class RegisterRequestDto {
  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final String nationalId;
  final String phoneNumber;
  final String dateOfBirth;
  final int gender;
  final int isMarried;
  final int governorate;
  final String medicalLicense;
  final bool isDoctor;

  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.nationalId,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.isMarried,
    required this.governorate,
    required this.medicalLicense,
    required this.isDoctor,
  });

  String get endpoint => isDoctor
      ? '/api/Authentication/register/doctor'
      : '/api/Authentication/register/patient';

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
        'phoneNumber': phoneNumber.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'nationalId': nationalId.trim(),
        'dateOfBirth': _normalizeBirthDate(dateOfBirth),
        'gender': gender,
        'isMarried': isMarried,
        'governorate': governorate,
        if (isDoctor) 'medicalLicense': medicalLicense.trim(),
      };

  static int mapGender(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'female':
        return 2;
      case 'male':
      default:
        return 1;
    }
  }

  static int mapMaritalStatus(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'yes':
        return 1;
      case 'no':
      default:
        return 2;
    }
  }

  static int mapGovernorate(String raw) {
    const governorates = <String, int>{
      'cairo': 1,
      'alexandria': 2,
      'giza': 3,
      'dakahlia': 4,
      'sharkia': 5,
      'qalyubia': 6,
      'beheira': 7,
      'gharbia': 8,
      'monufia': 9,
      'kafr el sheikh': 10,
      'fayoum': 11,
      'beni suef': 12,
      'minya': 13,
      'asyut': 14,
      'sohag': 15,
      'qena': 16,
      'luxor': 17,
      'aswan': 18,
      'red sea': 19,
      'new valley': 20,
      'matrouh': 21,
      'north sinai': 22,
      'south sinai': 23,
      'ismailia': 24,
      'suez': 25,
      'port said': 26,
      'damietta': 27,
    };

    return governorates[raw.trim().toLowerCase()] ?? 1;
  }

  static String _normalizeBirthDate(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) return normalized;
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return normalized;
    return parsed.toUtc().toIso8601String();
  }
}
