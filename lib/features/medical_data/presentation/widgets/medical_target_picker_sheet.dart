import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_account_option.dart';
import 'package:lung_diagnosis_app/features/medical_data/presentation/models/medical_target_mode.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class MedicalTargetPickerSheet extends StatelessWidget {
  final MedicalTargetMode mode;
  final List<MedicalTargetAccountOption> users;

  const MedicalTargetPickerSheet({
    super.key,
    required this.mode,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                mode == MedicalTargetMode.patient
                    ? 'Select patient account'
                    : 'Select doctor account',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    onTap: () => Navigator.pop(context, user),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: scheme.outlineVariant.withOpacity(0.65),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(
                        user.role == UserRole.patient
                            ? Icons.person_rounded
                            : Icons.medical_services_rounded,
                        color: scheme.primary,
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(user.email),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
