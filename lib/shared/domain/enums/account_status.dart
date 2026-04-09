enum UserAccountStatus { pending, approved, rejected, disabled }

extension UserAccountStatusX on UserAccountStatus {
  bool get isPending => this == UserAccountStatus.pending;
  bool get isApproved => this == UserAccountStatus.approved;
  bool get isRejected => this == UserAccountStatus.rejected;
  bool get isDisabled => this == UserAccountStatus.disabled;

  String get apiValue {
    switch (this) {
      case UserAccountStatus.pending:
        return 'Pending';
      case UserAccountStatus.approved:
        return 'Active';
      case UserAccountStatus.rejected:
        return 'Rejected';
      case UserAccountStatus.disabled:
        return 'Disabled';
    }
  }

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
    final normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case 'active':
      case 'approved':
        return UserAccountStatus.approved;
      case 'rejected':
        return UserAccountStatus.rejected;
      case 'disabled':
        return UserAccountStatus.disabled;
      case 'pending':
      default:
        return UserAccountStatus.pending;
    }
  }
}
