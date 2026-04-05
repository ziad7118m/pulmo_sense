class ResetPasswordRequestDto {
  final String emailOrPhone;
  final String code;
  final String newPassword;

  const ResetPasswordRequestDto({
    required this.emailOrPhone,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'emailOrPhone': emailOrPhone.trim(),
      'code': code.trim(),
      'newPassword': newPassword,
    };
  }
}
