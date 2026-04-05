class DashboardPatientView {
  final String userId;
  final String fullName;
  final String email;
  final String nationalId;
  final String gender;
  final String marital;
  final String avatarPath;
  final String matchedBy;

  const DashboardPatientView({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.nationalId,
    required this.gender,
    required this.marital,
    required this.avatarPath,
    required this.matchedBy,
  });

  String get firstName {
    final parts = _nameParts;
    return parts.isEmpty ? 'Patient' : parts.first;
  }

  String get lastName {
    final parts = _nameParts;
    return parts.length <= 1 ? '' : parts.skip(1).join(' ');
  }

  List<String> get _nameParts {
    return fullName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  }
}
