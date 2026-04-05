import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/core/errors/error_mapper.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/home/presentation/helpers/patient_access_resolver.dart';
import 'package:lung_diagnosis_app/features/home/presentation/models/resolved_patient_access.dart';
import 'package:lung_diagnosis_app/features/profile/domain/repositories/profile_repository.dart';

class PatientAccessController extends ChangeNotifier {
  PatientAccessController(this._profileRepository, this._authController);

  ProfileRepository _profileRepository;
  AuthController _authController;

  bool isLoading = false;
  bool isLookupFailure = false;
  String? lookupMessage;
  ResolvedPatientAccess? lastResolvedPatient;

  String _lastPatientId = '';
  String _lastNationalId = '';

  void bind({
    required ProfileRepository profileRepository,
    required AuthController authController,
  }) {
    _profileRepository = profileRepository;
    _authController = authController;
  }

  bool get canRetryLastLookup {
    return !isLoading && (_lastPatientId.isNotEmpty || _lastNationalId.isNotEmpty);
  }

  void clear() {
    if (!isLoading &&
        lookupMessage == null &&
        lastResolvedPatient == null &&
        !isLookupFailure &&
        _lastPatientId.isEmpty &&
        _lastNationalId.isEmpty) {
      return;
    }
    isLoading = false;
    isLookupFailure = false;
    lookupMessage = null;
    lastResolvedPatient = null;
    _lastPatientId = '';
    _lastNationalId = '';
    notifyListeners();
  }

  Future<ResolvedPatientAccess?> resolve({
    required String patientId,
    required String nationalId,
  }) async {
    final normalizedPatientId = patientId.trim();
    final normalizedNationalId = nationalId.trim();

    _lastPatientId = normalizedPatientId;
    _lastNationalId = normalizedNationalId;

    if (normalizedPatientId.isEmpty && normalizedNationalId.isEmpty) {
      isLookupFailure = false;
      lookupMessage = 'Enter a patient ID, a national ID, or both.';
      lastResolvedPatient = null;
      notifyListeners();
      return null;
    }

    if (normalizedNationalId.isNotEmpty && !_isValidNationalId(normalizedNationalId)) {
      isLookupFailure = false;
      lookupMessage = 'National ID must be exactly 14 digits.';
      lastResolvedPatient = null;
      notifyListeners();
      return null;
    }

    isLoading = true;
    isLookupFailure = false;
    lookupMessage = null;
    notifyListeners();

    try {
      final resolved = await PatientAccessResolver.resolve(
        patientId: normalizedPatientId,
        nationalId: normalizedNationalId,
        profileRepository: _profileRepository,
        authController: _authController,
      );

      lastResolvedPatient = resolved;
      isLookupFailure = false;
      lookupMessage = resolved == null
          ? 'No approved patient matched the entered details. Check the patient ID or national ID and try again.'
          : null;
      return resolved;
    } catch (error, stackTrace) {
      final failure = ErrorMapper.map(error, stackTrace);
      lastResolvedPatient = null;
      isLookupFailure = true;
      lookupMessage = failure.message.trim().isEmpty
          ? 'Could not look up the patient right now.'
          : failure.message;
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ResolvedPatientAccess?> retryLastLookup() {
    return resolve(
      patientId: _lastPatientId,
      nationalId: _lastNationalId,
    );
  }

  bool _isValidNationalId(String value) {
    return value.length == 14 && int.tryParse(value) != null;
  }
}
