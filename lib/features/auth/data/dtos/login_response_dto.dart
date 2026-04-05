import 'package:lung_diagnosis_app/features/auth/data/dtos/auth_user_dto.dart';

class LoginResponseDto {
  final String accessToken;
  final String refreshToken;
  final AuthUserDto user;

  const LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      user: AuthUserDto.fromJson(Map<String, dynamic>.from(json['user'] as Map? ?? const {})),
    );
  }
}
