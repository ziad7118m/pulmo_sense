import 'package:lung_diagnosis_app/features/shell/presentation/models/user_info_data.dart';

class UserInfoResolver {
  const UserInfoResolver._();

  static String fullName(UserInfoData data) {
    final value = data.fullName.trim();
    return value.isEmpty ? 'User' : value;
  }

  static String initials(String fullName) {
    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  static String normalizedValue(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? '-' : normalized;
  }
}
