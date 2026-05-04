import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lung_diagnosis_app/core/auth/token_store.dart';
import 'package:lung_diagnosis_app/core/config/app_config.dart';
import 'package:lung_diagnosis_app/core/network/api_client.dart';
import 'package:lung_diagnosis_app/core/session/app_session.dart';
import 'package:lung_diagnosis_app/features/articles/data/datasources/article_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/articles/data/repositories/article_repository_impl.dart';
import 'package:lung_diagnosis_app/features/articles/domain/repositories/article_repository.dart';
import 'package:lung_diagnosis_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:lung_diagnosis_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/data/api_diagnosis_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/data/fake_diagnosis_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/repositories/diagnosis_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_audio_usecase.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_record_usecase.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_xray_usecase.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/datasources/audio_history_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/datasources/xray_history_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/in_memory_diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/datasources/medical_profile_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/in_memory_medical_profile_store.dart';
import 'package:lung_diagnosis_app/features/medical_data/data/repositories/medical_profile_repository_impl.dart';
import 'package:lung_diagnosis_app/features/medical_data/domain/repositories/medical_profile_repository.dart';
import 'package:lung_diagnosis_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/profile/data/local_profile_store.dart';
import 'package:lung_diagnosis_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';

class AppDI {
  AppDI._();

  static const AppConfig config = AppConfig.dev;

  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final TokenStore tokenStore = TokenStore(_secureStorage);

  static final AppSession session = AppSession();
  static final LocalProfileStore _profileStore = LocalProfileStore();
  static final InMemoryMedicalProfileStore _medicalProfileStore =
      InMemoryMedicalProfileStore();

  static LocalProfileStore get profileStore => _profileStore;

  static late final ApiClient apiClient = ApiClient(
    config: config,
    tokenProvider: () => tokenStore.getAccessToken(),
    refreshTokenProvider: () => tokenStore.getRefreshToken(),
    onSessionRefreshed: (accessToken, refreshToken) => tokenStore.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    ),
    onUnauthorized: () => tokenStore.clear(),
  );

  static late final AuthRepository authRepo = AuthRepositoryImpl(
    remote: AuthRemoteDataSource(apiClient),
    local: AuthLocalDataSource(tokenStore),
  );

  static AuthRepository get authRepository => authRepo;

  static late final DiagnosisRepository diagnosisRepo =
      _buildDiagnosisRepository();
  static late final ArticleRepository articleRepo = _buildArticleRepository();
  static final MedicalProfileRepository medicalProfileRepo =
      _buildMedicalProfileRepository();
  static final ProfileRepository profileRepo = _buildProfileRepository();

  static late final AnalyzeRecordUseCase analyzeRecordUseCase =
      AnalyzeRecordUseCase(diagnosisRepo);
  static late final AnalyzeAudioUseCase analyzeAudioUseCase =
      AnalyzeAudioUseCase(diagnosisRepo);
  static late final AnalyzeXrayUseCase analyzeXrayUseCase =
      AnalyzeXrayUseCase(diagnosisRepo);

  static late final DiagnosisHistoryRepository historyRepo;

  static DiagnosisRepository _buildDiagnosisRepository() {
    return config.useApi
        ? ApiDiagnosisRepository(apiClient)
        : FakeDiagnosisRepository();
  }

  static ArticleRepository _buildArticleRepository() {
    return ArticleRepositoryImpl(
      remote: ArticleRemoteDataSource(apiClient),
    );
  }

  static MedicalProfileRepository _buildMedicalProfileRepository() {
    return MedicalProfileRepositoryImpl(
      remote: MedicalProfileRemoteDataSource(apiClient),
      local: _medicalProfileStore,
    );
  }

  static ProfileRepository _buildProfileRepository() {
    return ProfileRepositoryImpl(
      remote: ProfileRemoteDataSource(apiClient),
      local: _profileStore,
    );
  }

  static Future<void> init() async {
    historyRepo = InMemoryDiagnosisHistoryRepository(
      currentUserId: () => session.userId,
      xrayRemoteDataSource:
          config.useApi ? XrayHistoryRemoteDataSource(apiClient) : null,
      audioRemoteDataSource:
          config.useApi ? AudioHistoryRemoteDataSource(apiClient) : null,
    );
  }
}
