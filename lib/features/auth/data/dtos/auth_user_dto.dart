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
    return AuthUserDto(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['name'] ?? '').toString(),
      role: (json['role'] ?? 'patient').toString(),
      status: (json['status'] ?? 'pending').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
