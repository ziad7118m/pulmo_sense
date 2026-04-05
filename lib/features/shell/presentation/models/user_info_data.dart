class UserInfoData {
  final String fullName;
  final String email;
  final String nationalId;
  final String gender;
  final String marital;
  final String roleText;
  final String accountId;
  final String avatarPath;

  const UserInfoData({
    required this.fullName,
    required this.email,
    required this.nationalId,
    required this.gender,
    required this.marital,
    required this.roleText,
    required this.accountId,
    required this.avatarPath,
  });

  String get firstName {
    final parts = fullName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    return parts.isEmpty ? 'User' : parts.first;
  }

  String get lastName {
    final parts = fullName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length <= 1) return '';
    return parts.skip(1).join(' ');
  }
}
