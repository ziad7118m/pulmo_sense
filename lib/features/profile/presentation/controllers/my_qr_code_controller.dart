import 'package:flutter/foundation.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/models/my_qr_code_view_data.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/models/qr_payload_type.dart';

class MyQrCodeController extends ChangeNotifier {
  MyQrCodeController({
    required AuthController authController,
    required ProfileController profileController,
  })  : _authController = authController,
        _profileController = profileController {
    _authController.addListener(_handleExternalChange);
    _profileController.addListener(_handleExternalChange);
  }

  final AuthController _authController;
  final ProfileController _profileController;

  QrPayloadType _selectedType = QrPayloadType.accountId;
  String? _userId;
  String? _nationalId;
  bool _isLoading = false;

  MyQrCodeViewData get viewData => MyQrCodeViewData(
        selectedType: _selectedType,
        userId: _userId,
        nationalId: _nationalId,
        isLoading: _isLoading,
      );

  Future<void> load() async {
    final uid = (_authController.currentUserId ?? '').trim();
    if (uid.isEmpty) {
      _setData(userId: null, nationalId: null, isLoading: false);
      return;
    }

    _setData(isLoading: true);

    final currentProfile = _profileController.profile?.userId == uid
        ? _profileController.profile
        : await _profileController.loadProfile(uid, createIfMissing: true);

    final normalizedNationalId = (currentProfile?.nationalId ?? '').trim();
    _setData(
      userId: uid,
      nationalId: normalizedNationalId.isEmpty ? null : normalizedNationalId,
      isLoading: false,
    );
  }

  void selectPayloadType(QrPayloadType value) {
    if (_selectedType == value) return;
    _selectedType = value;
    notifyListeners();
  }

  void _handleExternalChange() {
    final uid = (_authController.currentUserId ?? '').trim();
    if (uid.isEmpty) {
      if (_userId != null || _nationalId != null || _isLoading) {
        _setData(userId: null, nationalId: null, isLoading: false);
      }
      return;
    }

    final currentProfile = _profileController.profile;
    if (currentProfile == null || currentProfile.userId != uid) return;

    final normalizedNationalId = currentProfile.nationalId.trim();
    final nextNationalId = normalizedNationalId.isEmpty ? null : normalizedNationalId;
    if (_userId == uid && _nationalId == nextNationalId) return;

    _setData(userId: uid, nationalId: nextNationalId, isLoading: false);
  }

  void _setData({
    String? userId,
    String? nationalId,
    bool? isLoading,
  }) {
    var changed = false;

    if (userId != _userId) {
      _userId = userId;
      changed = true;
    }

    if (nationalId != _nationalId) {
      _nationalId = nationalId;
      changed = true;
    }

    if (isLoading != null && isLoading != _isLoading) {
      _isLoading = isLoading;
      changed = true;
    }

    if (changed) notifyListeners();
  }

  @override
  void dispose() {
    _authController.removeListener(_handleExternalChange);
    _profileController.removeListener(_handleExternalChange);
    super.dispose();
  }
}
