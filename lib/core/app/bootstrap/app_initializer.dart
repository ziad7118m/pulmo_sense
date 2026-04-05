import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lung_diagnosis_app/core/di/app_di.dart';
import 'package:lung_diagnosis_app/core/di/local_auth_di.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/storage/diagnosis_item_entity.dart';

Future<void> initializeApplication() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(DiagnosisItemEntityAdapter());
  }

  await AppDI.init();
  await LocalAuthDI.init();
}
