import 'package:hive/hive.dart';
import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/datasources/xray_history_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/dtos/xray_history_entry_dto.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/storage/diagnosis_item_entity.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class HiveDiagnosisHistoryRepository extends DiagnosisHistoryRepository {
  static const String boxRecord = 'history_record';
  static const String boxStethoscope = 'history_stethoscope';
  static const String boxXray = 'history_xray';
  static const String boxLastResults = 'last_results';

  final Box<DiagnosisItemEntity> _record;
  final Box<DiagnosisItemEntity> _stethoscope;
  final Box<DiagnosisItemEntity> _xray;
  final Box _lastResults;
  final String? Function() _currentUserId;
  final XrayHistoryRemoteDataSource? _xrayRemoteDataSource;

  HiveDiagnosisHistoryRepository._(
    this._record,
    this._stethoscope,
    this._xray,
    this._lastResults,
    this._currentUserId,
    this._xrayRemoteDataSource,
  );

  static Future<HiveDiagnosisHistoryRepository> create({
    required String? Function() currentUserId,
    XrayHistoryRemoteDataSource? xrayRemoteDataSource,
  }) async {
    final record = await Hive.openBox<DiagnosisItemEntity>(boxRecord);
    final stetho = await Hive.openBox<DiagnosisItemEntity>(boxStethoscope);
    final xray = await Hive.openBox<DiagnosisItemEntity>(boxXray);
    final last = await Hive.openBox(boxLastResults);

    return HiveDiagnosisHistoryRepository._(
      record,
      stetho,
      xray,
      last,
      currentUserId,
      xrayRemoteDataSource,
    );
  }

  Box<DiagnosisItemEntity> _boxForType(String type) {
    switch (type) {
      case 'record':
        return _record;
      case 'stethoscope':
        return _stethoscope;
      default:
        return _xray;
    }
  }

  String _uid() {
    final value = _currentUserId()?.trim();
    if (value == null || value.isEmpty) {
      return 'anonymous';
    }
    return value;
  }

  String _resolveUserId(String? userId, {String? ownerUserId}) {
    final ownerNormalized = (ownerUserId ?? '').trim();
    if (ownerNormalized.isNotEmpty) {
      return ownerNormalized;
    }
    final normalized = (userId ?? '').trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return _uid();
  }

  String _lastResultKey(String ownerId, String type) => '${ownerId}_$type';

  String _itemResultKey(String ownerId, String type, String itemId) =>
      '${ownerId}_${type}_item_${itemId.trim()}';

  DiagnosisResult? _decodeResult(dynamic raw) {
    if (raw is Map) {
      return DiagnosisResult.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  @override
  bool supportsRemoteSync(DiagnosisKind kind) {
    return kind == DiagnosisKind.xray && _xrayRemoteDataSource != null;
  }

  @override
  Future<List<DiagnosisItem>> syncRemoteHistoryByKind(
    DiagnosisKind kind, {
    String? userId,
    String? ownerUserId,
  }) async {
    if (!supportsRemoteSync(kind)) {
      return getHistoryByKind(kind, userId: userId, ownerUserId: ownerUserId);
    }

    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    if (ownerId == 'anonymous') {
      return getHistoryByKind(kind, userId: userId, ownerUserId: ownerUserId);
    }

    final result = await _xrayRemoteDataSource!.fetchHistory();
    if (result is FailureResult<List<XrayHistoryEntryDto>>) {
      return getHistoryByKind(kind, userId: userId, ownerUserId: ownerUserId);
    }

    final entries = (result as Success<List<XrayHistoryEntryDto>>).value;
    await _replaceXrayHistory(ownerId, entries);
    return getHistoryByKind(kind, ownerUserId: ownerId);
  }

  Future<void> _replaceXrayHistory(
    String ownerId,
    List<XrayHistoryEntryDto> entries,
  ) async {
    final indicesToDelete = <int>[];
    for (int index = 0; index < _xray.length; index++) {
      final entity = _xray.getAt(index);
      if (entity?.userId == ownerId) {
        indicesToDelete.add(index);
      }
    }

    for (final index in indicesToDelete.reversed) {
      await _xray.deleteAt(index);
    }

    final resultKeysToDelete = <dynamic>[];
    final prefix = '${ownerId}_${DiagnosisKind.xray.storageKey}_item_';
    final lastResultKey = _lastResultKey(ownerId, DiagnosisKind.xray.storageKey);
    for (final key in _lastResults.keys) {
      final normalized = key.toString();
      if (normalized == lastResultKey || normalized.startsWith(prefix)) {
        resultKeysToDelete.add(key);
      }
    }
    if (resultKeysToDelete.isNotEmpty) {
      await _lastResults.deleteAll(resultKeysToDelete);
    }

    for (final entry in entries.reversed) {
      final item = entry.toDiagnosisItem();
      final entity = DiagnosisItemEntity.fromDomain(item);
      await _xray.add(
        DiagnosisItemEntity(
          id: entity.id,
          dateTime: entity.dateTime,
          diagnosis: entity.diagnosis,
          percentage: entity.percentage,
          imagePath: entity.imagePath,
          audioPath: entity.audioPath,
          waveSamples: entity.waveSamples,
          audioSourceType: entity.audioSourceType,
          userId: ownerId,
          createdByDoctorId: entity.createdByDoctorId,
          createdByDoctorName: entity.createdByDoctorName,
          targetPatientId: entity.targetPatientId,
          targetPatientName: entity.targetPatientName,
        ),
      );

      final diagnosisResult = entry.toDiagnosisResult();
      await _lastResults.put(
        _itemResultKey(ownerId, DiagnosisKind.xray.storageKey, item.id),
        diagnosisResult.toJson(),
      );
    }

    if (entries.isEmpty) {
      await _lastResults.delete(lastResultKey);
      return;
    }

    await _lastResults.put(lastResultKey, entries.first.toDiagnosisResult().toJson());
  }

  @override
  List<DiagnosisItem> getHistory(
    String type, {
    String? userId,
    String? ownerUserId,
  }) {
    final box = _boxForType(type);
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    final list = box.values.where((e) => e.userId == ownerId).toList();
    return list.reversed.map((e) => e.toDomain()).toList(growable: false);
  }

  @override
  DiagnosisItem getLatest(
    String type, {
    String? userId,
    String? ownerUserId,
  }) {
    final box = _boxForType(type);
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    for (int i = box.length - 1; i >= 0; i--) {
      final entity = box.getAt(i);
      if (entity == null || entity.userId != ownerId) {
        continue;
      }
      return entity.toDomain();
    }
    throw StateError('No history items for type=$type and user=$ownerId');
  }

  @override
  void addItem(
    String type,
    DiagnosisItem item, {
    String? userId,
    String? ownerUserId,
  }) {
    final box = _boxForType(type);
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    final entity = DiagnosisItemEntity.fromDomain(item);
    box.add(DiagnosisItemEntity(
      id: entity.id,
      dateTime: entity.dateTime,
      diagnosis: entity.diagnosis,
      percentage: entity.percentage,
      imagePath: entity.imagePath,
      audioPath: entity.audioPath,
      waveSamples: entity.waveSamples,
      audioSourceType: entity.audioSourceType,
      userId: ownerId,
      createdByDoctorId: entity.createdByDoctorId,
      createdByDoctorName: entity.createdByDoctorName,
      targetPatientId: entity.targetPatientId,
      targetPatientName: entity.targetPatientName,
    ));
  }

  @override
  Future<void> deleteItem(
    String type,
    String itemId, {
    String? userId,
    String? ownerUserId,
  }) async {
    final normalizedId = itemId.trim();
    if (normalizedId.isEmpty) {
      return;
    }

    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    final box = _boxForType(type);
    for (int index = box.length - 1; index >= 0; index--) {
      final entity = box.getAt(index);
      if (entity == null) {
        continue;
      }
      if (entity.userId != ownerId || entity.id != normalizedId) {
        continue;
      }
      await box.deleteAt(index);
      await _lastResults.delete(_itemResultKey(ownerId, type, normalizedId));
      return;
    }
  }

  @override
  DiagnosisResult? getLastResult(
    String type, {
    String? userId,
    String? ownerUserId,
  }) {
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    return _decodeResult(_lastResults.get(_lastResultKey(ownerId, type)));
  }

  @override
  void setLastResult(
    String type,
    DiagnosisResult result, {
    String? userId,
    String? ownerUserId,
  }) {
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    _lastResults.put(_lastResultKey(ownerId, type), result.toJson());
  }

  @override
  DiagnosisResult? getResultForItem(
    String type,
    String itemId, {
    String? userId,
    String? ownerUserId,
  }) {
    final normalizedId = itemId.trim();
    if (normalizedId.isEmpty) {
      return null;
    }
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    return _decodeResult(_lastResults.get(_itemResultKey(ownerId, type, normalizedId)));
  }

  @override
  void setResultForItem(
    String type,
    String itemId,
    DiagnosisResult result, {
    String? userId,
    String? ownerUserId,
  }) {
    final normalizedId = itemId.trim();
    if (normalizedId.isEmpty) {
      return;
    }
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    _lastResults.put(_itemResultKey(ownerId, type, normalizedId), result.toJson());
  }
}
