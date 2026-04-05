import 'package:lung_diagnosis_app/core/utils/extensions/string_extensions.dart';
import 'package:lung_diagnosis_app/features/auth/domain/entities/auth_user.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/models/stethoscope_patient_lookup_mode.dart';
import 'package:lung_diagnosis_app/features/diagnosis/stethoscope/presentation/models/stethoscope_patient_selection.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';

class StethoscopePatientResolver {
  final ProfileRepository _profileRepository;

  const StethoscopePatientResolver(this._profileRepository);

  Future<StethoscopePatientSelection> resolve({
    required String rawInput,
    required StethoscopePatientLookupMode patientMode,
    required List<AuthUser> patients,
  }) async {
    final original = rawInput.trim();
    final cleaned = original.replaceAll(RegExp(r'\s+'), '');
    final normalized = cleaned.normalizeDigits();

    final validationError = validateInput(
      rawInput: rawInput,
      patientMode: patientMode,
    );
    if (validationError != null) {
      return StethoscopePatientSelection.failure(
        queryValue: normalized,
        errorMessage: validationError,
      );
    }

    final AuthUser? resolvedUser;
    final String resolvedId;

    if (patientMode.isNationalId) {
      final userId = await _profileRepository.findUserIdByNationalId(normalized);
      if (userId == null || userId.trim().isEmpty) {
        return StethoscopePatientSelection.failure(
          queryValue: normalized,
          errorMessage: 'No patient found for this National ID',
        );
      }

      resolvedId = userId.trim();
      resolvedUser = _findPatientById(patients, resolvedId);
      if (resolvedUser == null) {
        return StethoscopePatientSelection.failure(
          queryValue: normalized,
          errorMessage: 'No approved patient account found for this National ID',
        );
      }
    } else {
      resolvedId = normalized;
      resolvedUser = _findPatientById(patients, resolvedId);
      if (resolvedUser == null) {
        return StethoscopePatientSelection.failure(
          queryValue: normalized,
          errorMessage: 'This account ID is not available in the current patient list',
        );
      }
    }

    final resolvedName = resolvedUser.displayName.trim();
    if (resolvedName.isEmpty) {
      return StethoscopePatientSelection.failure(
        queryValue: normalized,
        errorMessage: 'Unable to load patient data for this account',
      );
    }

    String? resolvedAvatarPath;
    try {
      final profile = await _profileRepository.getProfile(resolvedId);
      final avatarPath = profile?.avatarPath.trim() ?? '';
      if (avatarPath.isNotEmpty) {
        resolvedAvatarPath = avatarPath;
      }
    } catch (_) {}

    return StethoscopePatientSelection.success(
      queryValue: normalized,
      patientId: resolvedId,
      patientName: resolvedName,
      avatarPath: resolvedAvatarPath,
    );
  }

  String? validateInput({
    required String rawInput,
    required StethoscopePatientLookupMode patientMode,
  }) {
    final original = rawInput.trim();
    final cleaned = original.replaceAll(RegExp(r'\s+'), '');
    final normalized = cleaned.normalizeDigits();

    if (normalized.isEmpty) {
      final label = patientMode.inputLabel;
      return 'Please enter patient $label';
    }

    if (patientMode.isNationalId) {
      if (!cleaned.isAllDigits) return 'National ID must contain digits only';
      if (normalized.length != 14) return 'National ID must be 14 digits';
      return null;
    }

    if (!cleaned.isAllDigits) return 'Account ID must contain digits only';
    return null;
  }

  AuthUser? _findPatientById(List<AuthUser> patients, String userId) {
    for (final patient in patients) {
      if (patient.id == userId) return patient;
    }
    return null;
  }
}
