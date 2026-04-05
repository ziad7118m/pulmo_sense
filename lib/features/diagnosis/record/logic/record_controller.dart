import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lung_diagnosis_app/core/log/app_logger.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/services/audio_recorder_service.dart';
import 'package:lung_diagnosis_app/core/storage/audio_paths.dart';
import 'package:lung_diagnosis_app/core/utils/local_file_utils.dart';
import 'package:lung_diagnosis_app/core/validators/file_validators.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/value_objects/diagnosis_upload_request.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_record_usecase.dart';
import 'package:lung_diagnosis_app/features/diagnosis/logic/helpers/waveform_downsampler.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class RecordController extends ChangeNotifier {
  final AnalyzeRecordUseCase _analyzeRecord;
  final DiagnosisHistoryRepository _historyRepo;
  final AudioRecorderService _rec;

  RecordController({
    required AnalyzeRecordUseCase analyzeRecord,
    required DiagnosisHistoryRepository historyRepo,
    AudioRecorderService? recorder,
  })  : _analyzeRecord = analyzeRecord,
        _historyRepo = historyRepo,
        _rec = recorder ?? AudioRecorderService();

  StreamSubscription<double>? _ampSub;

  bool isRecording = false;
  bool isRecorded = false;
  bool isUploading = false;
  bool showSentCard = false;

  int recordingSeconds = 0;

  double level = 0.0;
  String? audioPath;

  final List<double> waveSamples = [];

  bool _savedToHistory = false;

  String? errorMessage;
  DateTime? lastCompletedAt;

  bool get canAnalyze => isRecorded && audioPath != null;

  DiagnosisItem? get latestHistoryItem {
    try {
      return _historyRepo.getLatestByKind(DiagnosisKind.record);
    } catch (_) {
      return null;
    }
  }

  static const int _targetBars = 160;

  void tickSecond() {
    if (!isRecording) return;
    recordingSeconds += 1;
    notifyListeners();
  }

  void _setError(String msg, {Object? data}) {
    errorMessage = msg;
    AppLogger.w(msg, data: data);
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> startRecording() async {
    if (isRecording) return;

    clearError();

    if (!_savedToHistory) {
      await LocalFileUtils.deleteIfExists(audioPath);
    }

    _savedToHistory = false;
    waveSamples.clear();
    level = 0.0;
    recordingSeconds = 0;

    final path = await AudioPaths.newRecordingPath(prefix: 'record');
    audioPath = path;

    isRecorded = false;
    showSentCard = false;

    await _rec.start(path: path);

    _ampSub?.cancel();
    _ampSub = _rec.amplitudeStream.listen((v) {
      final clamped = v.clamp(0.0, 1.0);
      level = clamped;
      waveSamples.add(clamped);
      notifyListeners();
    });

    isRecording = true;
    notifyListeners();
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;

    final path = await _rec.stop();
    isRecording = false;
    level = 0;

    notifyListeners();

    if (path == null) {
      await LocalFileUtils.deleteIfExists(audioPath);
      audioPath = null;
      isRecorded = false;
      waveSamples.clear();
      return;
    }

    audioPath = path;
    isRecorded = true;
    notifyListeners();
  }

  Future<bool> analyzeRecord() async {
    if (!canAnalyze) return false;

    clearError();

    final path = audioPath!;
    final failure = FileValidators.validateAudio(path);
    if (failure != null) {
      _setError(failure.message, data: failure.details);
      return false;
    }

    isUploading = true;
    notifyListeners();

    final Result<DiagnosisResult> res = await _analyzeRecord(
      DiagnosisUploadRequest(
        kind: DiagnosisKind.record,
        filePath: path,
      ),
    );

    res.when(
      success: (result) {
        _historyRepo.setLastResultByKind(DiagnosisKind.record, result);

        final compressed = waveSamples.isEmpty
            ? null
            : WaveformDownsampler.downsampleMaxBuckets(waveSamples, _targetBars);

        final item = DiagnosisItem(
          id: DiagnosisItem.nextId(),
          dateTime: DateFormat('d MMM yyyy • h:mm a').format(DateTime.now()),
          diagnosis: result.riskLevel,
          percentage: (result.confidence * 100).clamp(0, 100).toDouble(),
          audioPath: path,
          waveSamples: (compressed == null || compressed.isEmpty) ? null : compressed,
          audioSourceType: AudioSourceType.recorded,
        );

        _historyRepo.addItemByKind(DiagnosisKind.record, item);

        _savedToHistory = true;
        lastCompletedAt = DateTime.now();
        isUploading = false;
        notifyListeners();
        return true;
      },
      failure: (f) {
        isUploading = false;
        _setError(f.message, data: f.details);
        return false;
      },
    );

    return errorMessage == null;
  }

  void confirmSent() {
    showSentCard = true;
    notifyListeners();
  }

  Future<void> resetSession() async {
    if (!isRecording && !_savedToHistory && audioPath != null) {
      await LocalFileUtils.deleteIfExists(audioPath);
    }

    isRecording = false;
    isRecorded = false;
    isUploading = false;
    showSentCard = false;
    recordingSeconds = 0;
    level = 0.0;
    audioPath = null;
    waveSamples.clear();
    _savedToHistory = false;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ampSub?.cancel();
    _rec.dispose();

    if (!_savedToHistory) {
      LocalFileUtils.deleteIfExistsSync(audioPath);
    }

    super.dispose();
  }
}
