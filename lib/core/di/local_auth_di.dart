import 'package:lung_diagnosis_app/core/di/app_di.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_service.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_store.dart';
import 'package:lung_diagnosis_app/features/auth_local/logic/local_auth_controller.dart';

class LocalAuthDI {
  static late final LocalAuthStore store;
  static late final LocalAuthService service;
  static late final LocalAuthController controller;

  static Future<void> init() async {
    store = LocalAuthStore();
    service = LocalAuthService(store, AppDI.profileStore);
    controller = LocalAuthController(service, AppDI.session);
    await controller.init();
  }
}
