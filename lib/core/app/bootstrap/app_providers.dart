import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:lung_diagnosis_app/core/di/app_di.dart';
import 'package:lung_diagnosis_app/core/di/local_auth_di.dart';
import 'package:lung_diagnosis_app/core/theme/theme_controller.dart';
import 'package:lung_diagnosis_app/features/articles/domain/repositories/article_repository.dart';
import 'package:lung_diagnosis_app/features/articles/presentation/controllers/article_controller.dart';
import 'package:lung_diagnosis_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/auth/data/datasources/password_reset_local_data_source.dart';
import 'package:lung_diagnosis_app/features/auth/data/datasources/password_reset_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/auth/data/repositories/password_reset_repository_impl.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth_local/logic/local_auth_controller.dart';
import 'package:lung_diagnosis_app/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_audio_usecase.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_record_usecase.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_xray_usecase.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/home/presentation/controllers/home_doctor_controller.dart';
import 'package:lung_diagnosis_app/features/home/presentation/controllers/home_patient_controller.dart';
import 'package:lung_diagnosis_app/features/home/presentation/controllers/patient_access_controller.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/repositories/medical_profile_repository.dart';
import 'package:lung_diagnosis_app/features/medical_data/logic/medical_profile_controller.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/controllers/menu_screen_controller.dart';

List<SingleChildWidget> buildAppProviders() {
  return [
    ChangeNotifierProvider.value(value: AppDI.session),
    Provider<DiagnosisHistoryRepository>.value(value: AppDI.historyRepo),
    Provider<AnalyzeRecordUseCase>.value(value: AppDI.analyzeRecordUseCase),
    Provider<AnalyzeAudioUseCase>.value(value: AppDI.analyzeAudioUseCase),
    Provider<AnalyzeXrayUseCase>.value(value: AppDI.analyzeXrayUseCase),
    Provider<MedicalProfileRepository>.value(value: AppDI.medicalProfileRepo),
    Provider<ProfileRepository>.value(value: AppDI.profileRepo),
    Provider<ArticleRepository>.value(value: AppDI.articleRepo),
    Provider<AuthRepository>.value(value: AppDI.authRepo),
    Provider<PasswordResetRepository>(
      create: (_) => PasswordResetRepositoryImpl(
        local: PasswordResetLocalDataSource(LocalAuthDI.service),
        remote: AppDI.config.useApi
            ? PasswordResetRemoteDataSource(AuthRemoteDataSource(AppDI.apiClient))
            : null,
      ),
    ),
    ChangeNotifierProvider<LocalAuthController>.value(
      value: LocalAuthDI.controller,
    ),
    ChangeNotifierProxyProvider2<AuthRepository, LocalAuthController, AuthController>(
      create: (context) => AuthController(
        repository: context.read<AuthRepository>(),
        localDelegate: LocalAuthDI.controller,
        session: AppDI.session,
        config: AppDI.config,
      )..init(),
      update: (_, repository, localAuth, auth) {
        final controller =
            auth ??
            AuthController(
              repository: repository,
              localDelegate: localAuth,
              session: AppDI.session,
              config: AppDI.config,
            );
        controller.bind(localAuth, repository: repository, config: AppDI.config);
        return controller;
      },
    ),
    ChangeNotifierProxyProvider<ArticleRepository, ArticleController>(
      create: (context) => ArticleController(context.read<ArticleRepository>()),
      update: (context, repository, controller) => controller ?? ArticleController(repository),
    ),
    ChangeNotifierProvider<ThemeController>(
      create: (_) => ThemeController()..init(),
    ),
    Provider<DashboardController>(
      create: (context) => DashboardController(
        historyRepository: context.read<DiagnosisHistoryRepository>(),
        medicalProfileRepository: context.read<MedicalProfileRepository>(),
      ),
    ),
    Provider<HomeDoctorController>(
      create: (_) => const HomeDoctorController(),
    ),
    Provider<HomePatientController>(
      create: (_) => const HomePatientController(),
    ),
    Provider<MenuScreenController>(
      create: (_) => const MenuScreenController(),
    ),
    ChangeNotifierProxyProvider2<AuthController, ProfileRepository, ProfileController>(
      create: (context) => ProfileController(context.read<ProfileRepository>()),
      update: (_, auth, repository, profile) {
        final controller = profile ?? ProfileController(repository);
        controller.setUserId(auth.currentUserId);
        return controller;
      },
    ),
    ChangeNotifierProxyProvider2<AuthController, ProfileRepository, PatientAccessController>(
      create: (context) => PatientAccessController(
        context.read<ProfileRepository>(),
        context.read<AuthController>(),
      ),
      update: (_, auth, repository, patientAccess) {
        final controller = patientAccess ?? PatientAccessController(repository, auth);
        controller.bind(profileRepository: repository, authController: auth);
        return controller;
      },
    ),
    ChangeNotifierProxyProvider2<AuthController, MedicalProfileRepository, MedicalProfileController>(
      create: (context) =>
          MedicalProfileController(context.read<MedicalProfileRepository>()),
      update: (_, auth, repository, medical) {
        final controller = medical ?? MedicalProfileController(repository);
        controller.setCurrentUserId(auth.currentUserId);
        return controller;
      },
    ),
  ];
}
