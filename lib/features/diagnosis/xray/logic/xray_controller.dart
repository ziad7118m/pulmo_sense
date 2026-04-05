import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lung_diagnosis_app/core/log/app_logger.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/storage/image_paths.dart';
import 'package:lung_diagnosis_app/core/utils/local_file_utils.dart';
import 'package:lung_diagnosis_app/core/validators/file_validators.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/value_objects/diagnosis_upload_request.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_xray_usecase.dart';
import 'package:lung_diagnosis_app/features/diagnosis/logic/helpers/upload_progress_driver.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class XRayController extends ChangeNotifier {
  final AnalyzeXrayUseCase _analyzeXray;
  final DiagnosisHistoryRepository _historyRepo;
  final ImagePicker _picker;

  XRayController({
    required AnalyzeXrayUseCase analyzeXray,
    required DiagnosisHistoryRepository historyRepo,
    ImagePicker? picker,
  })  : _analyzeXray = analyzeXray,
        _historyRepo = historyRepo,
        _picker = picker ?? ImagePicker();

  File? selectedImage;
  late final UploadProgressDriver _uploadProgress = UploadProgressDriver(
    step: 0.06,
    onProgress: (value) {
      progress = value;
      notifyListeners();
    },
  );

  bool isUploading = false;
  bool showSentCard = false;
  double progress = 0.0;

  String? errorMessage;
  bool _savedToHistory = false;
  DateTime? lastCompletedAt;

  bool get canAnalyze => selectedImage != null && !isUploading;

  DiagnosisItem? get latestHistoryItem {
    try {
      return _historyRepo.getLatestByKind(DiagnosisKind.xray);
    } catch (_) {
      return null;
    }
  }

  void init() {}

  void _setError(String msg, {Object? data}) {
    errorMessage = msg;
    AppLogger.w(msg, data: data);
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    clearError();

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (picked == null) return;

    final saved = await ImagePaths.persistPickedImage(picked.path);

    final failure = FileValidators.validateImage(saved.path);
    if (failure != null) {
      _setError(failure.message, data: failure.details);
      LocalFileUtils.deleteIfExistsSync(saved.path);
      return;
    }

    if (!_savedToHistory && selectedImage != null && selectedImage!.path != saved.path) {
      LocalFileUtils.deleteIfExistsSync(selectedImage!.path);
    }

    selectedImage = saved;
    showSentCard = false;
    _savedToHistory = false;
    notifyListeners();
  }

  void removeImage() {
    if (!_savedToHistory && selectedImage != null) {
      LocalFileUtils.deleteIfExistsSync(selectedImage!.path);
    }
    selectedImage = null;
    progress = 0;
    isUploading = false;
    showSentCard = false;
    _savedToHistory = false;
    notifyListeners();
  }

  Future<bool> analyzeXray() async {
    if (!canAnalyze) return false;

    clearError();

    final path = selectedImage!.path;
    final failure = FileValidators.validateImage(path);
    if (failure != null) {
      _setError(failure.message, data: failure.details);
      return false;
    }

    isUploading = true;
    progress = 0;
    notifyListeners();

    _uploadProgress.start(from: 0);

    final Result<DiagnosisResult> res = await _analyzeXray(
      DiagnosisUploadRequest(
        kind: DiagnosisKind.xray,
        filePath: path,
      ),
    );
    _uploadProgress.stop();

    res.when(
      success: (result) {
        _historyRepo.setLastResultByKind(DiagnosisKind.xray, result);

        final item = DiagnosisItem(
          id: DiagnosisItem.nextId(),
          dateTime: DateFormat('d MMM yyyy • h:mm a').format(DateTime.now()),
          diagnosis: result.riskLevel,
          percentage: (result.confidence * 100).clamp(0, 100).toDouble(),
          imagePath: path,
        );
        _historyRepo.addItemByKind(DiagnosisKind.xray, item);

        _savedToHistory = true;
        lastCompletedAt = DateTime.now();
        isUploading = false;
        notifyListeners();
        return true;
      },
      failure: (f) {
        isUploading = false;
        progress = 0;
        _setError(f.message, data: f.details);
        return false;
      },
    );

    return errorMessage == null;
  }

  void confirmImageSent() {
    showSentCard = true;
    notifyListeners();
  }

  Future<void> resetSession() async {
    if (!_savedToHistory && selectedImage != null) {
      LocalFileUtils.deleteIfExistsSync(selectedImage!.path);
    }
    selectedImage = null;
    isUploading = false;
    showSentCard = false;
    progress = 0.0;
    errorMessage = null;
    _savedToHistory = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _uploadProgress.dispose();
    super.dispose();
  }
}
