class PasswordResetChallenge {
  final String deliveryHint;
  final String? debugCode;

  const PasswordResetChallenge({
    required this.deliveryHint,
    this.debugCode,
  });
}
