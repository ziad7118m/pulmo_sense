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
    final role = (json['role'] ?? json['userType'] ?? 'Patient').toString();
    final embeddedUser = json['user'];
    final userJson = embeddedUser is Map<String, dynamic>
        ? embeddedUser
        : embeddedUser is Map
            ? Map<String, dynamic>.from(embeddedUser)
            : json;

    return LoginResponseDto(
      accessToken: (json['token'] ?? json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      user: AuthUserDto(
        id: (userJson['id'] ?? userJson['userId'] ?? json['id'] ?? '').toString(),
        email: (userJson['email'] ?? json['email'] ?? '').toString(),
        displayName: (userJson['userName'] ??
                userJson['name'] ??
                userJson['displayName'] ??
                json['userName'] ??
                json['name'] ??
                json['displayName'] ??
                '').toString(),
        role: (userJson['role'] ?? userJson['userType'] ?? role).toString(),
        status: (userJson['status'] ?? userJson['userStatus'] ?? json['status'] ?? 'Active')
            .toString(),
      ),
    );
  }
}
