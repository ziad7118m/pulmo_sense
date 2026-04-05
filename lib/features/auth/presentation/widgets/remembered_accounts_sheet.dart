import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/remembered_account_option.dart';

class RememberedAccountsSheet extends StatelessWidget {
  final List<RememberedAccountOption> accounts;
  final ValueChanged<RememberedAccountOption> onAccountSelected;
  final ValueChanged<RememberedAccountOption> onAccountRemoved;

  const RememberedAccountsSheet({
    super.key,
    required this.accounts,
    required this.onAccountSelected,
    required this.onAccountRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        itemCount: accounts.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: scheme.outlineVariant,
        ),
        itemBuilder: (_, i) {
          final account = accounts[i];
          final email = account.email.trim();
          final avatarPath = account.avatarPath.trim();
          final hasAvatar = avatarPath.isNotEmpty && File(avatarPath).existsSync();
          final roleLabel = account.roleLabel.trim();

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              backgroundImage: hasAvatar ? FileImage(File(avatarPath)) : null,
              child: hasAvatar
                  ? null
                  : Icon(Icons.person_rounded, color: scheme.primary),
            ),
            title: Text(
              account.displayName,
              style: const TextStyle(fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              [email, roleLabel]
                  .where((entry) => entry.trim().isNotEmpty)
                  .join(' • '),
              style: TextStyle(color: scheme.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: 'Remove',
              onPressed: () => onAccountRemoved(account),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ),
            onTap: () => onAccountSelected(account),
          );
        },
      ),
    );
  }
}
