import 'package:hive/hive.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/storage/diagnosis_item_entity.dart';

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

  HiveDiagnosisHistoryRepository._(
    this._record,
    this._stethoscope,
    this._xray,
    this._lastResults,
    this._currentUserId,
  );

  static Future<HiveDiagnosisHistoryRepository> create({
    required String? Function() currentUserId,
  }) async {
    final record = await Hive.openBox<DiagnosisItemEntity>(boxRecord);
    final stetho = await Hive.openBox<DiagnosisItemEntity>(boxStethoscope);
    final xray = await Hive.openBox<DiagnosisItemEntity>(boxXray);
    final last = await Hive.openBox(boxLastResults);

    return HiveDiagnosisHistoryRepository._(record, stetho, xray, last, currentUserId);
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
    final raw = _lastResults.get('${ownerId}_$type');
    if (raw == null) {
      return null;
    }

    if (raw is Map) {
      return DiagnosisResult.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  @override
  void setLastResult(
    String type,
    DiagnosisResult result, {
    String? userId,
    String? ownerUserId,
  }) {
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    _lastResults.put('${ownerId}_$type', result.toJson());
  }
}
