import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:lung_diagnosis_app/core/errors/error_mapper.dart';
import 'package:lung_diagnosis_app/core/failures/failure.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/utils/id_generator.dart';
import 'package:lung_diagnosis_app/core/utils/unit.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/password_reset_challenge.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_models.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/local_auth_store.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/models/local_registration_profile_seed.dart';
import 'package:lung_diagnosis_app/features/auth_local/data/models/remembered_account.dart';
import 'package:lung_diagnosis_app/features/profile/data/local_profile.dart';
import 'package:lung_diagnosis_app/features/profile/data/local_profile_store.dart';

class _LocalPasswordResetTicket {
  final String userId;
  final String code;
  final DateTime expiresAt;
  final bool isVerified;

  const _LocalPasswordResetTicket({
    required this.userId,
    required this.code,
    required this.expiresAt,
    this.isVerified = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  _LocalPasswordResetTicket copyWith({
    bool? isVerified,
  }) {
    return _LocalPasswordResetTicket(
      userId: userId,
      code: code,
      expiresAt: expiresAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class LocalAuthService {
  final LocalAuthStore _store;
  final LocalProfileStore _profileStore;
  final Map<String, _LocalPasswordResetTicket> _passwordResetTickets =
      <String, _LocalPasswordResetTicket>{};
  final Random _random = Random();

  LocalAuthService(this._store, this._profileStore);

  String _hash(String raw) => sha256.convert(utf8.encode(raw)).toString();

  String _id() => IdGenerator.next(prefix: 'user');

  String _normalizeLookup(String emailOrPhone) => emailOrPhone.trim().toLowerCase();

  Future<List<LocalUser>> _sortedUsers() async {
    final all = await _store.getAllUsers();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  Future<List<LocalUser>> _usersWhere(bool Function(LocalUser user) predicate) async {
    final all = await _sortedUsers();
    return all.where(predicate).toList();
  }

  Future<List<LocalUser>> _approvedUsersByRole(LocalRole role) async {
    final approved = await approvedUsers();
    return approved.where((user) => user.role == role).toList();
  }

  Future<void> _updateUser(
    String userId,
    LocalUser Function(LocalUser current) transform,
  ) async {
    final user = await _store.getUserById(userId);
    if (user == null) return;
    await _store.upsertUser(transform(user));
  }

  LocalProfile _mergeProfileData(
    LocalProfile current,
    LocalRegistrationProfileSeed? profileSeed,
  ) {
    if (profileSeed == null || profileSeed.isEmpty) return current;

    return current.copyWith(
      nationalId: profileSeed.nationalId.trim().isEmpty
          ? current.nationalId
          : profileSeed.nationalId.trim(),
      address: profileSeed.address.trim().isEmpty
          ? current.address
          : profileSeed.address.trim(),
      phone: profileSeed.phone.trim().isEmpty
          ? current.phone
          : profileSeed.phone.trim(),
      birthDate: profileSeed.birthDate.trim().isEmpty
          ? current.birthDate
          : profileSeed.birthDate.trim(),
      gender: profileSeed.gender.trim().isEmpty
          ? current.gender
          : profileSeed.gender.trim(),
      marital: profileSeed.maritalStatus.trim().isEmpty
          ? current.marital
          : profileSeed.maritalStatus.trim(),
      doctorLicense: profileSeed.doctorLicense.trim().isEmpty
          ? current.doctorLicense
          : profileSeed.doctorLicense.trim(),
      updatedAt: DateTime.now(),
    );
  }

  Future<RememberedAccount?> _buildRememberedAccount(Map<String, String> entry) async {
    final email = (entry['email'] ?? '').trim();
    final password = (entry['password'] ?? '').trim();
    if (email.isEmpty) return null;

    LocalRole? role;
    var avatarPath = '';
    var name = '';

    try {
      final user = await _store.findByEmail(email);
      if (user != null) {
        role = user.role;
        name = user.name;
        try {
          final profile = await _profileStore.getOrCreate(user.id);
          avatarPath = profile.avatarPath;
        } catch (_) {}
      }
    } catch (_) {}

    return RememberedAccount(
      email: email,
      password: password,
      role: role,
      avatarPath: avatarPath,
      name: name,
    );
  }

  String _generateResetCode() {
    final value = 100000 + _random.nextInt(900000);
    return value.toString();
  }

  String _maskDeliveryHint(String emailOrPhone) {
    final value = emailOrPhone.trim();
    if (value.isEmpty) return '';
    if (value.contains('@')) {
      final parts = value.split('@');
      final name = parts.first;
      final domain = parts.length > 1 ? parts.last : '';
      if (name.isEmpty) {
        return domain.isEmpty ? '***' : '***@$domain';
      }
      final prefix = name.length <= 2 ? '${name.substring(0, 1)}*' : '${name.substring(0, 2)}***';
      return '$prefix@$domain';
    }
    if (value.length <= 4) return '***$value';
    return '***${value.substring(value.length - 4)}';
  }

  Future<LocalUser?> _findUserByEmailOrPhone(String emailOrPhone) async {
    final normalized = emailOrPhone.trim();
    if (normalized.isEmpty) return null;

    if (normalized.contains('@')) {
      return _store.findByEmail(normalized.toLowerCase());
    }

    final userId = await _profileStore.findUserIdByPhone(normalized);
    if (userId == null || userId.trim().isEmpty) return null;
    return _store.getUserById(userId);
  }

  _LocalPasswordResetTicket? _getValidPasswordResetTicket(String emailOrPhone) {
    final key = _normalizeLookup(emailOrPhone);
    final ticket = _passwordResetTickets[key];
    if (ticket == null) return null;
    if (!ticket.isExpired) return ticket;
    _passwordResetTickets.remove(key);
    return null;
  }

  Future<void> ensureSeedAdmin() async {
    final all = await _store.getAllUsers();
    final hasAdmin = all.any((u) => u.role == LocalRole.admin);
    if (hasAdmin) return;

    final admin = LocalUser(
      id: _id(),
      email: 'admin@local',
      name: 'Local Admin',
      passwordHash: _hash('123456'),
      role: LocalRole.admin,
      status: AccountStatus.approved,
      createdAt: DateTime.now(),
    );

    await _store.upsertUser(admin);
  }

  Future<Result<LocalUser>> register({
    required String email,
    required String name,
    required String password,
    LocalRole role = LocalRole.patient,
    LocalRegistrationProfileSeed? profileSeed,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = name.trim();

    if (normalizedEmail.isEmpty ||
        !normalizedEmail.contains('@') ||
        !normalizedEmail.contains('.')) {
      return const FailureResult(
        AppFailure(type: FailureType.validation, message: 'Invalid email'),
      );
    }

    if (normalizedName.isEmpty) {
      return const FailureResult(
        AppFailure(type: FailureType.validation, message: 'Name is required'),
      );
    }

    if (password.length < 8) {
      return const FailureResult(
        AppFailure(
          type: FailureType.validation,
          message: 'Password must be at least 8 chars',
        ),
      );
    }

    try {
      final existing = await _store.findByEmail(normalizedEmail);
      if (existing != null) {
        return const FailureResult(
          AppFailure(type: FailureType.validation, message: 'Email already exists'),
        );
      }

      final user = LocalUser(
        id: _id(),
        email: normalizedEmail,
        name: normalizedName,
        passwordHash: _hash(password),
        role: role,
        status: AccountStatus.pending,
        createdAt: DateTime.now(),
      );

      await _store.upsertUser(user);

      final currentProfile = await _profileStore.getOrCreate(user.id);
      final mergedProfile = _mergeProfileData(currentProfile, profileSeed);
      if (mergedProfile != currentProfile) {
        await _profileStore.upsert(mergedProfile);
      }

      return Success(user);
    } catch (err, st) {
      return FailureResult(ErrorMapper.map(err, st));
    }
  }

  Future<Result<LocalUser>> login({
    required String email,
    required String password,
  }) async {
    final emailLower = email.trim().toLowerCase();

    try {
      final user = await _store.findByEmail(emailLower);
      if (user == null || user.passwordHash != _hash(password)) {
        return const FailureResult(
          AppFailure(type: FailureType.unauthorized, message: 'Wrong email or password'),
        );
      }

      if (user.status == AccountStatus.disabled) {
        return const FailureResult(
          AppFailure(type: FailureType.forbidden, message: 'Account is disabled'),
        );
      }

      await _store.setSession(LocalSession(userId: user.id));
      await _store.rememberAccount(email: user.email, password: password);
      await _profileStore.getOrCreate(user.id);

      return Success(user);
    } catch (err, st) {
      return FailureResult(ErrorMapper.map(err, st));
    }
  }

  Future<Result<PasswordResetChallenge>> requestPasswordReset(String emailOrPhone) async {
    final normalized = emailOrPhone.trim();
    if (normalized.isEmpty) {
      return const FailureResult(
        AppFailure(type: FailureType.validation, message: 'Email or phone is required'),
      );
    }

    try {
      final user = await _findUserByEmailOrPhone(normalized);
      if (user == null) {
        return const FailureResult(
          AppFailure(type: FailureType.notFound, message: 'Account not found'),
        );
      }

      final code = _generateResetCode();
      final key = _normalizeLookup(normalized);
      _passwordResetTickets[key] = _LocalPasswordResetTicket(
        userId: user.id,
        code: code,
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );

      return Success(
        PasswordResetChallenge(
          deliveryHint: _maskDeliveryHint(normalized),
          debugCode: code,
        ),
      );
    } catch (err, st) {
      return FailureResult(ErrorMapper.map(err, st));
    }
  }

  Future<Result<Unit>> verifyPasswordResetCode({
    required String emailOrPhone,
    required String code,
  }) async {
    final normalizedCode = code.trim();
    if (normalizedCode.length != 6) {
      return const FailureResult(
        AppFailure(type: FailureType.validation, message: 'Enter the 6-digit code'),
      );
    }

    final ticket = _getValidPasswordResetTicket(emailOrPhone);
    if (ticket == null) {
      return const FailureResult(
        AppFailure(
          type: FailureType.validation,
          message: 'Reset request expired or not found',
        ),
      );
    }

    if (ticket.code != normalizedCode) {
      return const FailureResult(
        AppFailure(type: FailureType.validation, message: 'Incorrect verification code'),
      );
    }

    final key = _normalizeLookup(emailOrPhone);
    _passwordResetTickets[key] = ticket.copyWith(isVerified: true);
    return const Success(Unit.value);
  }

  Future<Result<Unit>> resetPassword({
    required String emailOrPhone,
    required String code,
    required String newPassword,
  }) async {
    if (newPassword.length < 8) {
      return const FailureResult(
        AppFailure(type: FailureType.validation, message: 'Password must be at least 8 characters'),
      );
    }

    final ticket = _getValidPasswordResetTicket(emailOrPhone);
    if (ticket == null) {
      return const FailureResult(
        AppFailure(
          type: FailureType.validation,
          message: 'Reset request expired or not found',
        ),
      );
    }

    if (ticket.code != code.trim() || !ticket.isVerified) {
      return const FailureResult(
        AppFailure(type: FailureType.validation, message: 'Verification step is incomplete'),
      );
    }

    try {
      await _updateUser(
        ticket.userId,
        (user) => user.copyWith(passwordHash: _hash(newPassword)),
      );
      _passwordResetTickets.remove(_normalizeLookup(emailOrPhone));
      return const Success(Unit.value);
    } catch (err, st) {
      return FailureResult(ErrorMapper.map(err, st));
    }
  }

  Future<void> logout() => _store.setSession(null);

  Future<LocalUser?> currentUser() async {
    final session = await _store.getSession();
    if (session == null) return null;
    return _store.getUserById(session.userId);
  }

  Future<List<LocalUser>> pendingUsers() =>
      _usersWhere((user) => user.status == AccountStatus.pending);

  Future<List<LocalUser>> approvedUsers() => _usersWhere(
        (user) => user.status == AccountStatus.approved && user.role != LocalRole.admin,
      );

  Future<List<LocalUser>> rejectedUsers() =>
      _usersWhere((user) => user.status == AccountStatus.rejected);

  Future<List<LocalUser>> disabledUsers() =>
      _usersWhere((user) => user.status == AccountStatus.disabled);

  Future<List<LocalUser>> doctors() => _approvedUsersByRole(LocalRole.doctor);

  Future<List<LocalUser>> patients() => _approvedUsersByRole(LocalRole.patient);

  Future<void> approveUser(String userId, {LocalRole? role}) {
    return _updateUser(
      userId,
      (user) => user.copyWith(
        status: AccountStatus.approved,
        role: role ?? user.role,
      ),
    );
  }

  Future<void> rejectUser(String userId) {
    return _updateUser(
      userId,
      (user) => user.copyWith(status: AccountStatus.rejected),
    );
  }

  Future<void> disableUser(String userId) {
    return _updateUser(
      userId,
      (user) => user.copyWith(status: AccountStatus.disabled),
    );
  }

  Future<void> enableUser(String userId) {
    return _updateUser(
      userId,
      (user) => user.copyWith(status: AccountStatus.approved),
    );
  }

  Future<void> deleteUser(String userId) async {
    final current = await currentUser();
    await _store.deleteUser(userId);
    await _profileStore.deleteProfile(userId);

    if (current != null && current.id == userId) {
      await logout();
    }
  }

  Future<void> updateUserName(String userId, String newName) {
    return _updateUser(
      userId,
      (user) => user.copyWith(name: newName),
    );
  }

  Future<List<RememberedAccount>> rememberedAccounts() async {
    final items = await _store.getRememberedAccounts();
    final resolved = await Future.wait(items.map(_buildRememberedAccount));
    return resolved.whereType<RememberedAccount>().toList();
  }

  Future<void> forgetRememberedAccount(String email) =>
      _store.forgetRememberedAccount(email);
}
