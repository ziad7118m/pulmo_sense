class ForgotPasswordRequestDto {
  final String emailOrPhone;

  const ForgotPasswordRequestDto({
    required this.emailOrPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': emailOrPhone.trim(),
    };
  }
}
