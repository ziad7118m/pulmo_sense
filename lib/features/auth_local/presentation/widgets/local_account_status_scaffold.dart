import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/auth_local/presentation/models/local_account_status_view_data.dart';
import 'package:lung_diagnosis_app/routes/app_routes.dart';

class LocalAccountStatusScaffold extends StatelessWidget {
  final LocalAccountStatusViewData viewData;
  final Future<void> Function() onLogout;

  const LocalAccountStatusScaffold({
    super.key,
    required this.viewData,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final button = viewData.useFilledButton
        ? FilledButton(onPressed: onLogout, child: Text(viewData.actionLabel))
        : OutlinedButton(onPressed: onLogout, child: Text(viewData.actionLabel));

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(viewData.title),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                viewData.icon,
                size: 72,
                color: viewData.iconColor,
              ),
              const SizedBox(height: 14),
              Text(
                viewData.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: button,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
