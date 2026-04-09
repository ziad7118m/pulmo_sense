import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';


enum AdminUsersKind { pending, active, disabled, rejected, doctors, patients }

extension AdminUsersKindX on AdminUsersKind {
  String get title {
    switch (this) {
      case AdminUsersKind.pending:
        return 'Pending';
      case AdminUsersKind.active:
        return 'Active';
      case AdminUsersKind.disabled:
        return 'Disabled';
      case AdminUsersKind.rejected:
        return 'Rejected';
      case AdminUsersKind.doctors:
        return 'Doctors';
      case AdminUsersKind.patients:
        return 'Patients';
    }
  }

  String get tileSubtitle {
    switch (this) {
      case AdminUsersKind.pending:
        return 'Review new accounts';
      case AdminUsersKind.active:
        return 'Approved users';
      case AdminUsersKind.disabled:
        return 'Temporarily blocked';
      case AdminUsersKind.rejected:
        return 'Declined requests';
      case AdminUsersKind.doctors:
        return 'All doctor accounts';
      case AdminUsersKind.patients:
        return 'All patient accounts';
    }
  }

  IconData get tileIcon {
    switch (this) {
      case AdminUsersKind.pending:
        return Icons.how_to_reg_rounded;
      case AdminUsersKind.active:
        return Icons.verified_user_rounded;
      case AdminUsersKind.disabled:
        return Icons.block_rounded;
      case AdminUsersKind.rejected:
        return Icons.close_rounded;
      case AdminUsersKind.doctors:
        return Icons.medical_services_rounded;
      case AdminUsersKind.patients:
        return Icons.people_alt_rounded;
    }
  }

  IconData get emptyIcon {
    switch (this) {
      case AdminUsersKind.pending:
        return Icons.inbox_rounded;
      case AdminUsersKind.active:
        return Icons.people_alt_rounded;
      case AdminUsersKind.disabled:
        return Icons.lock_open_rounded;
      case AdminUsersKind.rejected:
        return Icons.block_rounded;
      case AdminUsersKind.doctors:
        return Icons.medical_services_rounded;
      case AdminUsersKind.patients:
        return Icons.person_rounded;
    }
  }

  String get emptyTitle {
    switch (this) {
      case AdminUsersKind.pending:
        return 'No pending accounts';
      case AdminUsersKind.active:
        return 'No active accounts';
      case AdminUsersKind.disabled:
        return 'No disabled accounts';
      case AdminUsersKind.rejected:
        return 'No rejected accounts';
      case AdminUsersKind.doctors:
        return 'No doctors';
      case AdminUsersKind.patients:
        return 'No patients';
    }
  }

  String get emptyMessage {
    switch (this) {
      case AdminUsersKind.pending:
        return 'New signup requests will appear here.';
      case AdminUsersKind.active:
        return 'Active users from the backend will appear here.';
      case AdminUsersKind.disabled:
        return 'Disabled users from the backend will appear here.';
      case AdminUsersKind.rejected:
        return 'Rejected users from the backend will appear here.';
      case AdminUsersKind.doctors:
        return 'Doctor accounts from the backend will appear here.';
      case AdminUsersKind.patients:
        return 'Patient accounts from the backend will appear here.';
    }
  }

  Future<List<AuthUser>> loadUsers(AuthController controller) {
    switch (this) {
      case AdminUsersKind.pending:
        return controller.fetchPending();
      case AdminUsersKind.active:
        return controller.fetchApproved();
      case AdminUsersKind.disabled:
        return controller.fetchDisabled();
      case AdminUsersKind.rejected:
        return controller.fetchRejected();
      case AdminUsersKind.doctors:
        return controller.fetchDoctors();
      case AdminUsersKind.patients:
        return controller.fetchPatients();
    }
  }
}
