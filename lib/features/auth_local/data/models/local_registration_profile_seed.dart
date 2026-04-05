class LocalRegistrationProfileSeed {
  final String nationalId;
  final String address;
  final String phone;
  final String birthDate;
  final String gender;
  final String maritalStatus;
  final String doctorLicense;

  const LocalRegistrationProfileSeed({
    this.nationalId = '',
    this.address = '',
    this.phone = '',
    this.birthDate = '',
    this.gender = '',
    this.maritalStatus = '',
    this.doctorLicense = '',
  });

  bool get isEmpty =>
      nationalId.trim().isEmpty &&
      address.trim().isEmpty &&
      phone.trim().isEmpty &&
      birthDate.trim().isEmpty &&
      gender.trim().isEmpty &&
      maritalStatus.trim().isEmpty &&
      doctorLicense.trim().isEmpty;
}
