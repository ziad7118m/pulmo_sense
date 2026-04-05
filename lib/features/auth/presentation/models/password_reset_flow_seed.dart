class PasswordResetFlowSeed {
  final String emailOrPhone;
  final String deliveryHint;
  final String? debugCode;
  final String? verificationCode;

  const PasswordResetFlowSeed({
    required this.emailOrPhone,
    this.deliveryHint = '',
    this.debugCode,
    this.verificationCode,
  });

  bool get hasVerificationCode =>
      (verificationCode ?? '').trim().isNotEmpty;

  bool get hasDeliveryHint => deliveryHint.trim().isNotEmpty;

  bool get hasDebugCode => (debugCode ?? '').trim().isNotEmpty;

  PasswordResetFlowSeed copyWith({
    String? emailOrPhone,
    String? deliveryHint,
    String? debugCode,
    String? verificationCode,
  }) {
    return PasswordResetFlowSeed(
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      deliveryHint: deliveryHint ?? this.deliveryHint,
      debugCode: debugCode ?? this.debugCode,
      verificationCode: verificationCode ?? this.verificationCode,
    );
  }

  PasswordResetFlowSeed withoutDebugCode() {
    return PasswordResetFlowSeed(
      emailOrPhone: emailOrPhone,
      deliveryHint: deliveryHint,
      verificationCode: verificationCode,
    );
  }
}
