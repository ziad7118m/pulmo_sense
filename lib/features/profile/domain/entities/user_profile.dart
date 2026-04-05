class UserProfile {
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

  const UserProfile({
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

  UserProfile copyWith({
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
    return UserProfile(
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

  static UserProfile empty(String userId) {
    return UserProfile(
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
