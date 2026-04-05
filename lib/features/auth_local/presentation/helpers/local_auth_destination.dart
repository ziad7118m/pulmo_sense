import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/helpers/auth_destination_resolver.dart';

Widget resolveLocalAuthDestination(AuthUser? user) {
  return resolveAuthDestination(user);
}
