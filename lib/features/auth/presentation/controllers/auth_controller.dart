import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/core/failures/failure.dart';
import 'package:lung_diagnosis_app/core/config/app_config.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/session/app_session.dart';
import 'package:lung_diagnosis_app/core/utils/unit.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_session.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/login_credentials.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/register_account_request.dart';
import 'package:lung_diagnosis_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/helpers/local_auth_bridge.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/remembered_account_option.dart';
import 'package:lung_diagnosis_app/features/auth_local/logic/local_auth_controller.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/account_status.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';

class AuthController extends ChangeNotifier {
  AuthRepository _repository;
  LocalAuthController _delegate;
  final AppSession _session;
  AppConfig _config;

  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _didInit = false;

  AuthController({
    required AuthRepository repository,
    required LocalAuthController localDelegate,
    required AppSession session,
    required AppConfig config,
  })  : _repository = repository,
        _delegate = localDelegate,
        _session = session,
        _config = config {
    _delegate.addListener(_handleDelegateChanged);
  }

  bool get _useApi => _config.useApi;

  Future<void> init() async {
    if (_didInit) return;
    _didInit = true;

    if (!_useApi) {
      _syncSession(currentUser);
      return;
    }

    _setLoading(true);
    final cachedUser = await _repository.getCachedUser();
    if (cachedUser != null) {
      _currentUser = cachedUser;
      _syncSession(cachedUser);
      _setLoading(false);
      return;
    }

    final result = await _repository.restoreSession();
    _setLoading(false);
    if (result is Success<AuthSession>) {
      _error = null;
      _currentUser = result.value.user;
      _syncSession(_currentUser);
      notifyListeners();
      return;
    }

    _syncSession(null);
  }

  void bind(
    LocalAuthController delegate, {
    AuthRepository? repository,
    AppConfig? config,
  }) {
    if (!identical(_delegate, delegate)) {
      _delegate.removeListener(_handleDelegateChanged);
      _delegate = delegate;
      _delegate.addListener(_handleDelegateChanged);
    }
    if (repository != null) {
      _repository = repository;
    }
    if (config != null) {
      _config = config;
    }
    _syncSession(currentUser);
    notifyListeners();
  }

  AuthUser? get currentUser {
    if (_useApi) return _currentUser;
    final user = _delegate.user;
    if (user == null) return null;
    return LocalAuthBridge.authUserFromLocalUser(user);
  }

  String? get currentUserId => currentUser?.id;
  String? get currentUserName => currentUser?.displayName;
  UserRole? get currentUserRole => currentUser?.role;
  bool get isApiMode => _useApi;
  bool get isLocalMode => !_useApi;
  bool get isLoading => _useApi ? _isLoading : _delegate.isLoading;
  String? get error => _useApi ? _error : _delegate.error;
  bool get isAuthenticated => currentUser != null;
  bool get isDoctor => currentUserRole == UserRole.doctor;
  bool get isPatient => currentUserRole == UserRole.patient;
  bool get isAdmin => currentUserRole == UserRole.admin;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (!_useApi) {
      return _delegate.login(email, password);
    }

    clearError();
    _setLoading(true);
    final result = await _repository.login(
      LoginCredentials(
        email: email,
        password: password,
      ),
    );
    _setLoading(false);

    if (result is FailureResult<AuthSession>) {
      _error = result.failure.message;
      notifyListeners();
      return false;
    }

    final session = (result as Success<AuthSession>).value;
    _currentUser = session.user;
    _syncSession(session.user);
    notifyListeners();
    return true;
  }

  Future<bool> register(RegisterAccountRequest request) async {
    if (!_useApi) {
      return _delegate.register(
        email: request.email,
        name: '${request.firstName} ${request.lastName}'.trim(),
        password: request.password,
        role: LocalAuthBridge.localRoleFromUserRole(request.role),
        profileSeed: LocalAuthBridge.registrationSeedFromRequest(request),
      );
    }

    clearError();
    _setLoading(true);
    final result = await _repository.register(request);
    _setLoading(false);

    var ok = false;
    result.when(
      success: (_) {
        _error = null;
        ok = true;
      },
      failure: (failure) {
        _error = failure.message;
      },
    );

    notifyListeners();
    return ok;
  }

  Future<void> logout() async {
    if (!_useApi) {
      await _delegate.logout();
      _syncSession(null);
      notifyListeners();
      return;
    }

    await _repository.logout();
    _currentUser = null;
    _error = null;
    _syncSession(null);
    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    if (!_useApi) {
      await _delegate.refreshCurrentUser();
      _syncSession(currentUser);
      notifyListeners();
      return;
    }

    final result = await _repository.fetchCurrentUser();
    if (result is FailureResult<AuthUser>) {
      _error = result.failure.message;
      notifyListeners();
      return;
    }

    _error = null;
    _currentUser = (result as Success<AuthUser>).value;
    _syncSession(_currentUser);
    notifyListeners();
  }

  Future<void> updateDisplayName(String displayName) async {
    final normalized = displayName.trim();
    if (!_useApi) {
      await _delegate.updateMyName(normalized);
      return;
    }

    final user = _currentUser;
    if (user == null || normalized.isEmpty || normalized == user.displayName) {
      return;
    }

    _currentUser = user.copyWith(displayName: normalized);
    await _repository.saveCachedUser(_currentUser!);
    notifyListeners();
  }

  Future<List<RememberedAccountOption>> rememberedAccountOptions() async {
    if (_useApi) return const <RememberedAccountOption>[];

    final accounts = await _delegate.rememberedAccounts();
    return accounts
        .map(LocalAuthBridge.rememberedAccountOptionFromLocal)
        .toList(growable: false);
  }

  Future<void> forgetRememberedAccount(String email) {
    if (_useApi) return Future.value();
    return _delegate.forgetRememberedAccount(email);
  }

  Future<List<AuthUser>> fetchPending() async {
    if (_useApi) {
      return await _fetchUsersRemote(status: UserAccountStatus.pending);
    }
    return (await _delegate.fetchPending())
        .map(LocalAuthBridge.authUserFromLocalUser)
        .toList(growable: false);
  }

  Future<List<AuthUser>> fetchApproved() async {
    if (!_useApi) {
      return (await _delegate.fetchApproved())
          .map(LocalAuthBridge.authUserFromLocalUser)
          .toList(growable: false);
    }

    final items = await _fetchUsersRemote(status: UserAccountStatus.approved);
    return items.where((user) => !user.role.isAdmin).toList(growable: false);
  }

  Future<List<AuthUser>> fetchRejected() async {
    if (_useApi) {
      return await _fetchUsersRemote(status: UserAccountStatus.rejected);
    }
    return (await _delegate.fetchRejected())
        .map(LocalAuthBridge.authUserFromLocalUser)
        .toList(growable: false);
  }

  Future<List<AuthUser>> fetchDisabled() async {
    if (_useApi) {
      return await _fetchUsersRemote(status: UserAccountStatus.disabled);
    }
    return (await _delegate.fetchDisabled())
        .map(LocalAuthBridge.authUserFromLocalUser)
        .toList(growable: false);
  }

  Future<List<AuthUser>> fetchDoctors() async {
    if (_useApi) {
      return await _fetchUsersRemote(
        status: UserAccountStatus.approved,
        role: UserRole.doctor,
      );
    }
    return (await _delegate.fetchDoctors())
        .map(LocalAuthBridge.authUserFromLocalUser)
        .toList(growable: false);
  }

  Future<List<AuthUser>> fetchPatients() async {
    if (_useApi) {
      return await _fetchUsersRemote(
        status: UserAccountStatus.approved,
        role: UserRole.patient,
      );
    }
    return (await _delegate.fetchPatients())
        .map(LocalAuthBridge.authUserFromLocalUser)
        .toList(growable: false);
  }

  Future<AuthUser?> findApprovedPatientById(String userId) async {
    if (!_useApi) {
      final user = await _delegate.findApprovedPatientById(userId);
      if (user == null) return null;
      return LocalAuthBridge.authUserFromLocalUser(user);
    }

    final result = await _repository.findApprovedPatientById(userId);
    return _unwrapNullableUser(result);
  }

  Future<AuthUser?> findApprovedPatientByNationalId(
    String nationalId, {
    required Future<String?> Function(String nationalId) resolveUserId,
  }) async {
    if (!_useApi) {
      final user = await _delegate.findApprovedPatientByNationalId(
        nationalId,
        resolveUserId: resolveUserId,
      );
      if (user == null) return null;
      return LocalAuthBridge.authUserFromLocalUser(user);
    }

    final result = await _repository.findApprovedPatientByNationalId(nationalId);
    return _unwrapNullableUser(result);
  }

  Future<void> approve(String id, {UserRole? role}) async {
    if (!_useApi) {
      return _delegate.approve(
        id,
        role: role == null ? null : LocalAuthBridge.localRoleFromUserRole(role),
      );
    }
    await _runRemoteMutation(_repository.approveUser(id, role: role));
  }

  Future<void> reject(String id) async {
    if (!_useApi) return _delegate.reject(id);
    await _runRemoteMutation(_repository.rejectUser(id));
  }

  Future<void> disable(String id) async {
    if (!_useApi) return _delegate.disable(id);
    await _runRemoteMutation(_repository.disableUser(id));
  }

  Future<void> enable(String id) async {
    if (!_useApi) return _delegate.enable(id);
    await _runRemoteMutation(_repository.enableUser(id));
  }

  Future<void> deleteUser(String id) async {
    if (!_useApi) return _delegate.deleteUser(id);
    await _runRemoteMutation(_repository.deleteUser(id));
  }

  void clearError() {
    _error = null;
    _delegate.clearError();
    if (_useApi) {
      notifyListeners();
    }
  }

  void _handleDelegateChanged() {
    if (!_useApi) {
      _syncSession(currentUser);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _syncSession(AuthUser? user) {
    if (user == null) {
      _session.clear();
      return;
    }
    _session.setAuthenticatedUser(
      userId: user.id,
      roleName: user.role.name,
    );
  }

  Future<List<AuthUser>> _fetchUsersRemote({
    UserAccountStatus? status,
    UserRole? role,
  }) async {
    final result = await _repository.fetchUsers(status: status, role: role);
    if (result is FailureResult<List<AuthUser>>) {
      _error = result.failure.message;
      notifyListeners();
      return const <AuthUser>[];
    }

    _error = null;
    return (result as Success<List<AuthUser>>).value;
  }

  Future<void> _runRemoteMutation(Future<Result<Unit>> future) async {
    final result = await future;
    if (result is FailureResult<Unit>) {
      _error = result.failure.message;
      notifyListeners();
      throw StateError(result.failure.message);
    }

    _error = null;
    notifyListeners();
  }

  AuthUser? _unwrapNullableUser(Result<AuthUser?> result) {
    if (result is FailureResult<AuthUser?>) {
      if (result.failure.type != FailureType.notFound) {
        _error = result.failure.message;
        notifyListeners();
      }
      return null;
    }

    _error = null;
    return (result as Success<AuthUser?>).value;
  }

  @override
  void dispose() {
    _delegate.removeListener(_handleDelegateChanged);
    super.dispose();
  }
}
