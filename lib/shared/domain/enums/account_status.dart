enum UserAccountStatus { pending, approved, rejected, disabled }

extension UserAccountStatusX on UserAccountStatus {
  bool get isPending => this == UserAccountStatus.pending;
  bool get isApproved => this == UserAccountStatus.approved;
  bool get isRejected => this == UserAccountStatus.rejected;
  bool get isDisabled => this == UserAccountStatus.disabled;

  String get apiValue => name;

  String get displayName {
    switch (this) {
      case UserAccountStatus.pending:
        return 'Pending';
      case UserAccountStatus.approved:
        return 'Approved';
      case UserAccountStatus.rejected:
        return 'Rejected';
      case UserAccountStatus.disabled:
        return 'Disabled';
    }
  }

  static UserAccountStatus fromValue(String raw) {
    return UserAccountStatus.values.firstWhere(
      (value) => value.name == raw.trim().toLowerCase(),
      orElse: () => UserAccountStatus.pending,
    );
  }
}
