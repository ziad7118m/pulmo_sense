import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/controllers/local_account_status_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/widgets/local_account_status_scaffold.dart';
import 'package:lung_diagnosis_app/routes/app_routes.dart';
import 'package:provider/provider.dart';

class LocalRejectedPage extends StatelessWidget {
  const LocalRejectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LocalAccountStatusController(
      authController: context.read<AuthController>(),
    );

    return LocalAccountStatusScaffold(
      viewData: controller.buildRejectedViewData(),
      onLogout: () async {
        await controller.logout();
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      },
    );
  }
}
