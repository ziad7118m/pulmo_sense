class AuthUserDto {
  final String id;
  final String email;
  final String displayName;
  final String role;
  final String status;
  final DateTime? createdAt;

  const AuthUserDto({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    this.createdAt,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] ?? json['userType'] ?? 'Patient').toString();
    final statusRaw = (json['status'] ?? json['userStatus'] ?? 'Pending').toString();
    return AuthUserDto(
      id: (json['id'] ?? json['userId'] ?? json['Id'] ?? json['UserId'] ?? '').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      displayName: (json['displayName'] ??
              json['name'] ??
              json['userName'] ??
              json['Name'] ??
              json['UserName'] ??
              '').toString(),
      role: role,
      status: statusRaw,
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['CreatedAt'] ?? '').toString()),
    );
  }
}
