enum LocalRole { admin, doctor, patient }
enum AccountStatus { pending, approved, rejected, disabled }

class LocalUser {
  final String id;
  final String email;
  final String name;
  final String passwordHash;
  final LocalRole role;
  final AccountStatus status;
  final DateTime createdAt;

  const LocalUser({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  LocalUser copyWith({
    String? id,
    String? email,
    String? name,
    String? passwordHash,
    LocalRole? role,
    AccountStatus? status,
    DateTime? createdAt,
  }) {
    return LocalUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'name': name,
    'passwordHash': passwordHash,
    'role': role.name,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  static LocalUser fromMap(Map data) {
    return LocalUser(
      id: (data['id'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      passwordHash: (data['passwordHash'] ?? '').toString(),
      role: LocalRole.values.firstWhere(
            (e) => e.name == (data['role'] ?? 'patient').toString(),
        orElse: () => LocalRole.patient,
      ),
      status: AccountStatus.values.firstWhere(
            (e) => e.name == (data['status'] ?? 'pending').toString(),
        orElse: () => AccountStatus.pending,
      ),
      createdAt: DateTime.tryParse((data['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class LocalSession {
  final String userId;

  const LocalSession({required this.userId});

  Map<String, dynamic> toMap() => {'userId': userId};

  static LocalSession? fromMap(dynamic data) {
    if (data is Map) {
      final id = (data['userId'] ?? '').toString();
      if (id.isEmpty) return null;
      return LocalSession(userId: id);
    }
    return null;
  }
}
