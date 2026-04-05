class RegisterRequestDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String nationalId;
  final String address;
  final String phone;
  final String birthDate;
  final String gender;
  final String maritalStatus;
  final String doctorLicense;

  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.nationalId = '',
    this.address = '',
    this.phone = '',
    this.birthDate = '',
    this.gender = '',
    this.maritalStatus = '',
    this.doctorLicense = '',
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'role': role.trim(),
        'nationalId': nationalId.trim(),
        'address': address.trim(),
        'phone': phone.trim(),
        'birthDate': birthDate.trim(),
        'gender': gender.trim(),
        'maritalStatus': maritalStatus.trim(),
        'doctorLicense': doctorLicense.trim(),
      };
}
