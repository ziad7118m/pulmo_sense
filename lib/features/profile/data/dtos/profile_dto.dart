class ProfileDto {
  final String userId;
  final String nationalId;
  final String address;
  final String phone;
  final String birthDate;
  final String gender;
  final String maritalStatus;
  final String doctorLicense;
  final String avatarPath;
  final DateTime updatedAt;

  const ProfileDto({
    required this.userId,
    required this.nationalId,
    required this.address,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.maritalStatus,
    required this.doctorLicense,
    required this.avatarPath,
    required this.updatedAt,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      userId: (json['userId'] ?? json['id'] ?? '').toString(),
      nationalId: (json['nationalId'] ?? json['nationalID'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      birthDate: (json['birthDate'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      maritalStatus: (json['maritalStatus'] ?? json['marital'] ?? '').toString(),
      doctorLicense: (json['doctorLicense'] ?? json['license'] ?? '').toString(),
      avatarPath: (json['avatarPath'] ?? json['avatarUrl'] ?? '').toString(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nationalId': nationalId,
      'address': address,
      'phone': phone,
      'birthDate': birthDate,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'doctorLicense': doctorLicense,
      'avatarPath': avatarPath,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
