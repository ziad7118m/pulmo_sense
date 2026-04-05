class LocalProfile {
  final String userId;
  final String nationalId;
  final String address;
  final String phone;
  final String birthDate;
  final String gender;
  final String marital;
  final String doctorLicense;
  final String avatarPath;
  final DateTime updatedAt;

  const LocalProfile({
    required this.userId,
    required this.nationalId,
    required this.address,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.marital,
    required this.doctorLicense,
    required this.avatarPath,
    required this.updatedAt,
  });

  LocalProfile copyWith({
    String? nationalId,
    String? address,
    String? phone,
    String? birthDate,
    String? gender,
    String? marital,
    String? doctorLicense,
    String? avatarPath,
    DateTime? updatedAt,
  }) {
    return LocalProfile(
      userId: userId,
      nationalId: nationalId ?? this.nationalId,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      marital: marital ?? this.marital,
      doctorLicense: doctorLicense ?? this.doctorLicense,
      avatarPath: avatarPath ?? this.avatarPath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nationalId': nationalId,
      'address': address,
      'phone': phone,
      'birthDate': birthDate,
      'gender': gender,
      'marital': marital,
      'doctorLicense': doctorLicense,
      'avatarPath': avatarPath,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static LocalProfile fromMap(dynamic raw) {
    if (raw is! Map) {
      throw ArgumentError('LocalProfile.fromMap expects Map');
    }
    final m = Map<String, dynamic>.from(raw);
    return LocalProfile(
      userId: (m['userId'] ?? '').toString(),
      nationalId: (m['nationalId'] ?? '').toString(),
      address: (m['address'] ?? '').toString(),
      phone: (m['phone'] ?? '').toString(),
      birthDate: (m['birthDate'] ?? '').toString(),
      gender: (m['gender'] ?? '').toString(),
      marital: (m['marital'] ?? '').toString(),
      doctorLicense: (m['doctorLicense'] ?? '').toString(),
      avatarPath: (m['avatarPath'] ?? '').toString(),
      updatedAt: DateTime.tryParse((m['updatedAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  static LocalProfile empty(String userId) {
    return LocalProfile(
      userId: userId,
      nationalId: '',
      address: '',
      phone: '',
      birthDate: '',
      gender: '',
      marital: '',
      doctorLicense: '',
      avatarPath: '',
      updatedAt: DateTime.now(),
    );
  }
}
