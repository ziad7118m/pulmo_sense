import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/session/app_session.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_models.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_service.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/models/local_registration_profile_seed.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/models/remembered_account.dart';

class LocalAuthController extends ChangeNotifier {
  final LocalAuthService _service;
  final AppSession _session;

  LocalAuthController(this._service, this._session);

  LocalUser? user;
  bool isLoading = false;
  String? error;

  void _syncSession(LocalUser? currentUser) {
    user = currentUser;
    if (currentUser == null) {
      _session.clear();
      return;
    }
    _session.setAuthenticatedUser(
      userId: currentUser.id,
      roleName: currentUser.role.name,
    );
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<bool> _runAuthAction(
    Future<bool> Function() action,
  ) async {
    clearError();
    _setLoading(true);
    final ok = await action();
    _setLoading(false);
    return ok;
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  Future<void> init() async {
    _setLoading(true);
    await _service.ensureSeedAdmin();
    _syncSession(await _service.currentUser());
    _setLoading(false);
  }

  Future<bool> login(String email, String password) {
    return _runAuthAction(() async {
      final result = await _service.login(email: email, password: password);
      var ok = false;

      result.when(
        success: (loggedUser) {
          _syncSession(loggedUser);
          ok = true;
        },
        failure: (failure) => error = failure.message,
      );

      return ok;
    });
  }

  Future<bool> register({
    required String email,
    required String name,
    required String password,
    required LocalRole role,
    LocalRegistrationProfileSeed? profileSeed,
  }) {
    return _runAuthAction(() async {
      final result = await _service.register(
        email: email,
        name: name,
        password: password,
        role: role,
        profileSeed: profileSeed,
      );

      var ok = false;
      result.when(
        success: (_) => ok = true,
        failure: (failure) => error = failure.message,
      );

      return ok;
    });
  }

  Future<void> logout() async {
    await _service.logout();
    _syncSession(null);
    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    _syncSession(await _service.currentUser());
    notifyListeners();
  }

  Future<void> updateMyName(String newName) async {
    final currentUser = user;
    if (currentUser == null) return;
    await _service.updateUserName(currentUser.id, newName);
    await refreshCurrentUser();
  }

  Future<List<LocalUser>> fetchPending() => _service.pendingUsers();
  Future<List<LocalUser>> fetchApproved() => _service.approvedUsers();
  Future<List<LocalUser>> fetchRejected() => _service.rejectedUsers();
  Future<List<LocalUser>> fetchDisabled() => _service.disabledUsers();
  Future<List<LocalUser>> fetchDoctors() => _service.doctors();
  Future<List<LocalUser>> fetchPatients() => _service.patients();

  Future<void> approve(String id, {LocalRole? role}) =>
      _service.approveUser(id, role: role);
  Future<void> reject(String id) => _service.rejectUser(id);
  Future<void> disable(String id) => _service.disableUser(id);
  Future<void> enable(String id) => _service.enableUser(id);
  Future<void> deleteUser(String id) => _service.deleteUser(id);

  Future<LocalUser?> findApprovedPatientById(String userId) async {
    final normalizedId = userId.trim();
    if (normalizedId.isEmpty) return null;

    final patients = await fetchPatients();
    for (final patient in patients) {
      if (patient.id.trim() == normalizedId) return patient;
    }
    return null;
  }

  Future<LocalUser?> findApprovedPatientByNationalId(
    String nationalId, {
    required Future<String?> Function(String nationalId) resolveUserId,
  }) async {
    final normalizedNationalId = nationalId.trim();
    if (normalizedNationalId.isEmpty) return null;

    final resolvedUserId = await resolveUserId(normalizedNationalId);
    if (resolvedUserId == null || resolvedUserId.trim().isEmpty) return null;
    return findApprovedPatientById(resolvedUserId);
  }

  Future<List<RememberedAccount>> rememberedAccounts() =>
      _service.rememberedAccounts();
  Future<void> forgetRememberedAccount(String email) =>
      _service.forgetRememberedAccount(email);
}
