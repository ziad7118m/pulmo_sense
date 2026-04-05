import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/account_disabled_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/account_pending_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/account_rejected_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/admin_home_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/login_screen.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/pages/main_layout_doctor.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/pages/main_layout_patient.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

Widget resolveAuthDestination(AuthUser? user) {
  if (user == null) return const LoginScreen();

  if (user.status.isPending) return const AccountPendingScreen();
  if (user.status.isRejected) return const AccountRejectedScreen();
  if (user.status.isDisabled) return const AccountDisabledScreen();

  if (user.role.isAdmin) return const AdminHomeScreen();
  if (user.role.isDoctor) return const MainLayoutDoctor();
  return const MainLayoutPatient();
}
