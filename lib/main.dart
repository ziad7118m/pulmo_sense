import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:lung_diagnosis_app/core/app/bootstrap/app_initializer.dart';
import 'package:lung_diagnosis_app/core/app/bootstrap/app_providers.dart';
import 'package:lung_diagnosis_app/core/theme/app_theme.dart';
import 'package:lung_diagnosis_app/core/theme/theme_controller.dart';
import 'package:lung_diagnosis_app/routes/app_router.dart';
import 'package:lung_diagnosis_app/routes/app_routes.dart';

Future<void> main() async {
  await initializeApplication();
  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Pulmo Sense',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: context.watch<ThemeController>().mode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
