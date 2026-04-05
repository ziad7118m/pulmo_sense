import 'package:lung_diagnosis_app/features/auth/domain/entities/password_reset_challenge.dart';

class PasswordResetChallengeDto {
  final String deliveryHint;
  final String? debugCode;

  const PasswordResetChallengeDto({
    required this.deliveryHint,
    this.debugCode,
  });

  factory PasswordResetChallengeDto.fromJson(Map<String, dynamic> json) {
    return PasswordResetChallengeDto(
      deliveryHint: (json['deliveryHint'] ?? json['maskedDestination'] ?? '').toString(),
      debugCode: (json['debugCode'] ?? '').toString().trim().isEmpty
          ? null
          : (json['debugCode'] ?? '').toString(),
    );
  }

  PasswordResetChallenge toDomain() {
    return PasswordResetChallenge(
      deliveryHint: deliveryHint,
      debugCode: debugCode,
    );
  }
}
