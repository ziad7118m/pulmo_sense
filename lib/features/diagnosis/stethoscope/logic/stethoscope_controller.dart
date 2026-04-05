import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lung_diagnosis_app/core/log/app_logger.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/core/services/audio_recorder_service.dart';
import 'package:lung_diagnosis_app/core/session/app_session.dart';
import 'package:lung_diagnosis_app/core/storage/audio_paths.dart';
import 'package:lung_diagnosis_app/core/utils/local_file_utils.dart';
import 'package:lung_diagnosis_app/core/validators/file_validators.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/usecases/analyze_audio_usecase.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/value_objects/diagnosis_upload_request.dart';
import 'package:lung_diagnosis_app/features/diagnosis/logic/helpers/upload_progress_driver.dart';
import 'package:lung_diagnosis_app/features/diagnosis/logic/helpers/waveform_downsampler.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/recipient_type.dart';

enum StethoscopeRecipient { patient, doctor }

class StethoscopeController extends ChangeNotifier {
  final AnalyzeAudioUseCase _analyzeAudio;
  final DiagnosisHistoryRepository _historyRepo;
  final AudioRecorderService _rec;
  final AppSession _session;

  final bool isDoctorMode;

  StethoscopeController({
    required AnalyzeAudioUseCase analyzeAudio,
    required DiagnosisHistoryRepository historyRepo,
    required AppSession session,
    this.isDoctorMode = true,
    AudioRecorderService? recorder,
  })  : _analyzeAudio = analyzeAudio,
        _historyRepo = historyRepo,
        _session = session,
        _rec = recorder ?? AudioRecorderService();

  StreamSubscription<double>? _ampSub;
  late final UploadProgressDriver _uploadProgress = UploadProgressDriver(
    step: 0.08,
    onProgress: (value) {
      progress = value;
      notifyListeners();
    },
  );

  bool isRecording = false;
  bool isUploading = false;
  bool showSentCard = false;

  /// Who is this audio intended for?
  /// - [patient] => doctor records/sends under a patient account.
  /// - [doctor]  => audio is saved to the doctor's own account (or received from another doctor).
  StethoscopeRecipient recipient = StethoscopeRecipient.patient;

  // ✅ For doctors: send/save this stethoscope result under a specific patient account id.
  String? targetPatientId;
  String? targetPatientName;

  void setRecipient(StethoscopeRecipient v) {
    if (recipient == v) return;
    recipient = v;
    if (recipient == StethoscopeRecipient.doctor) {
      // Avoid accidental sending when user switches to self mode.
      targetPatientId = null;
      targetPatientName = null;
    }
    notifyListeners();
  }

  void setTargetPatient(String? id, {String? name}) {
    targetPatientId = (id ?? '').trim().isEmpty ? null : id!.trim();
    targetPatientName = (name ?? '').trim().isEmpty ? null : name!.trim();
    notifyListeners();
  }

  double progress = 0;
  double level = 0;

  String? selectedAudioPath;

  AudioSourceType? get sourceType => _sourceType;

  Future<void> clearSelectedAudio({bool deleteFile = true}) async {
    if (isRecording) {
      await stopRecording();
    }
    if (deleteFile && !_savedToHistory) {
      await LocalFileUtils.deleteIfExists(selectedAudioPath);
    }
    selectedAudioPath = null;
    waveSamples.clear();
    level = 0;
    progress = 0;
    showSentCard = false;
    _savedToHistory = false;
    _sourceType = null;
    notifyListeners();
  }

  final List<double> waveSamples = [];

  bool _savedToHistory = false;
  AudioSourceType? _sourceType;

  String? errorMessage;
  String? successMessage;
  DateTime? lastCompletedAt;

  bool get canAnalyze => selectedAudioPath != null && !isUploading;

  DiagnosisItem? get latestHistoryItem {
    try {
      return _historyRepo.getLatestByKind(DiagnosisKind.stethoscope);
    } catch (_) {
      return null;
    }
  }

  static const int _targetBars = 160;

  void _setError(String msg, {Object? data}) {
    errorMessage = msg;
    AppLogger.w(msg, data: data);
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    successMessage = null;
    notifyListeners();
  }

  Future<void> startRecording() async {
    if (isRecording) return;

    if (!isDoctorMode) {
      _setError('Patients cannot record stethoscope audio. Please visit a doctor with the stethoscope device.');
      return;
    }

    clearError();

    if (!_savedToHistory && _sourceType != null) {
      await LocalFileUtils.deleteIfExists(selectedAudioPath);
    }

    _savedToHistory = false;
    _sourceType = AudioSourceType.recorded;

    waveSamples.clear();
    level = 0;

    final path = await AudioPaths.newRecordingPath(prefix: 'stethoscope');
    selectedAudioPath = path;
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

    if (path == null) {
      await LocalFileUtils.deleteIfExists(selectedAudioPath);
      selectedAudioPath = null;
      waveSamples.clear();
    } else {
      selectedAudioPath = path;
    }

    notifyListeners();
  }

  void setUploadedAudio(String path) {
    if (!isDoctorMode) {
      _setError('Patients cannot upload stethoscope audio. Please visit a doctor with the stethoscope device.');
      return;
    }

    clearError();

    if (!_savedToHistory && _sourceType != null) {
      // If replacing a previous local selection (recorded or uploaded) that wasn't saved, delete it.
      LocalFileUtils.deleteIfExistsSync(selectedAudioPath);
    }

    selectedAudioPath = path;
    showSentCard = false;

    waveSamples.clear();
    _savedToHistory = false;
    _sourceType = AudioSourceType.uploaded;

    notifyListeners();
  }

  Future<bool> analyzeStethoscope() async {
    if (!canAnalyze) return false;

    if (!isDoctorMode) {
      _setError('Patients cannot analyze stethoscope audio.');
      return false;
    }

    // In patient mode, doctors must pick the patient account before sending.
    if (isDoctorMode && recipient == StethoscopeRecipient.patient) {
      if (targetPatientId == null || targetPatientId!.trim().isEmpty) {
        _setError('Please select the patient account before sending the stethoscope audio.');
        return false;
      }
    }

    clearError();

    final path = selectedAudioPath!;
    final failure = FileValidators.validateAudio(path);
    if (failure != null) {
      _setError(failure.message, data: failure.details);
      return false;
    }

    isUploading = true;
    progress = 0;
    notifyListeners();

    _uploadProgress.start(from: 0);

    final Result<DiagnosisResult> res = await _analyzeAudio(
      DiagnosisUploadRequest(
        kind: DiagnosisKind.stethoscope,
        filePath: path,
        recipientType: recipient == StethoscopeRecipient.patient
            ? RecipientType.patient
            : RecipientType.self,
        targetPatientId: recipient == StethoscopeRecipient.patient
            ? targetPatientId?.trim()
            : null,
      ),
    );
    _uploadProgress.stop();

    res.when(
      success: (result) {
        _historyRepo.setLastResultByKind(DiagnosisKind.stethoscope, result);

        final compressed = waveSamples.isEmpty
            ? null
            : WaveformDownsampler.downsampleMaxBuckets(waveSamples, _targetBars);

        final doctorId = _session.userId;
        final item = DiagnosisItem(
          id: DiagnosisItem.nextId(),
          dateTime: DateFormat('d MMM yyyy • h:mm a').format(DateTime.now()),
          diagnosis: result.riskLevel,
          percentage: (result.confidence * 100).clamp(0, 100).toDouble(),
          audioPath: path,
          waveSamples: (compressed == null || compressed.isEmpty) ? null : compressed,
          audioSourceType: _sourceType,
          createdByDoctorId: doctorId,
          targetPatientId: recipient == StethoscopeRecipient.patient ? targetPatientId : null,
          targetPatientName: recipient == StethoscopeRecipient.patient ? targetPatientName : null,
        );
        if (doctorId == null || doctorId.trim().isEmpty) {
          _setError('Missing active session. Please login again.');
          isUploading = false;
          progress = 0;
          notifyListeners();
          return false;
        }

        if (recipient == StethoscopeRecipient.doctor) {
          // ✅ Save ONLY under the doctor's own account ("my" stethoscope recordings).
          _historyRepo.addItemByKind(
            DiagnosisKind.stethoscope,
            item,
            userId: doctorId,
          );
        } else {
          // ✅ Save under target patient id (doctor -> patient) AND also under doctor history.
          final pid = targetPatientId?.trim();
          if (pid == null || pid.isEmpty) {
            _setError('Please select the patient account before sending the stethoscope audio.');
            isUploading = false;
            progress = 0;
            notifyListeners();
            return false;
          }

          // Patient copy (owner = patient)
          _historyRepo.addItemByKind(
            DiagnosisKind.stethoscope,
            item,
            userId: pid,
          );

          // Doctor outbox copy (owner = doctor) includes target patient metadata
          final doctorCopy = DiagnosisItem(
            id: DiagnosisItem.nextId(),
            dateTime: item.dateTime,
            diagnosis: item.diagnosis,
            percentage: item.percentage,
            audioPath: item.audioPath,
            waveSamples: item.waveSamples,
            audioSourceType: item.audioSourceType,
            createdByDoctorId: doctorId,
            targetPatientId: pid,
            targetPatientName: targetPatientName,
          );
          _historyRepo.addItemByKind(
            DiagnosisKind.stethoscope,
            doctorCopy,
            userId: doctorId,
          );
        }

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

  void confirmSent() {
    showSentCard = true;
    successMessage = recipient == StethoscopeRecipient.doctor
        ? 'Stethoscope audio saved to your account.'
        : 'Stethoscope audio saved and sent successfully.';
    notifyListeners();
  }

  Future<void> resetSession() async {
    if (isRecording) {
      await stopRecording();
    }
    await clearSelectedAudio(deleteFile: !_savedToHistory);
    isUploading = false;
    progress = 0;
    showSentCard = false;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ampSub?.cancel();
    _rec.dispose();
    _uploadProgress.dispose();

    if (!_savedToHistory && _sourceType == AudioSourceType.recorded) {
      LocalFileUtils.deleteIfExistsSync(selectedAudioPath);
    }

    super.dispose();
  }
}
