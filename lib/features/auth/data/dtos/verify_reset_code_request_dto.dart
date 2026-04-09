class VerifyResetCodeRequestDto {
  final String emailOrPhone;
  final String code;

  const VerifyResetCodeRequestDto({
    required this.emailOrPhone,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': emailOrPhone.trim(),
      'code': code.trim(),
    };
  }
}
