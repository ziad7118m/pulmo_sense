import 'package:lung_diagnosis_app/core/result/result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/datasources/xray_history_remote_data_source.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/diagnosis_history_repository.dart';
import 'package:lung_diagnosis_app/features/diagnosis/history/data/dtos/xray_history_entry_dto.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

class InMemoryDiagnosisHistoryRepository extends DiagnosisHistoryRepository {
  final String? Function() _currentUserId;
  final XrayHistoryRemoteDataSource? _xrayRemoteDataSource;

  final Map<String, List<DiagnosisItem>> _itemsByBucket =
      <String, List<DiagnosisItem>>{};
  final Map<String, DiagnosisResult> _lastResults =
      <String, DiagnosisResult>{};
  final Map<String, DiagnosisResult> _itemResults =
      <String, DiagnosisResult>{};

  InMemoryDiagnosisHistoryRepository({
    required String? Function() currentUserId,
    XrayHistoryRemoteDataSource? xrayRemoteDataSource,
  }) : _currentUserId = currentUserId,
       _xrayRemoteDataSource = xrayRemoteDataSource;

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
    if (result is! Success<List<XrayHistoryEntryDto>>) {
      return getHistoryByKind(kind, userId: userId, ownerUserId: ownerUserId);
    }

    final entries = List<XrayHistoryEntryDto>.from(result.value)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final bucket = _bucketKey(ownerId, kind.storageKey);
    final items = entries.map((entry) => entry.toDiagnosisItem()).toList(growable: false);
    _itemsByBucket[bucket] = List<DiagnosisItem>.from(items);

    _clearStoredResults(ownerId, kind.storageKey);
    for (final entry in entries) {
      final item = entry.toDiagnosisItem();
      _itemResults[_itemResultKey(ownerId, kind.storageKey, item.id)] =
          entry.toDiagnosisResult();
    }

    if (entries.isEmpty) {
      _lastResults.remove(_lastResultKey(ownerId, kind.storageKey));
    } else {
      _lastResults[_lastResultKey(ownerId, kind.storageKey)] =
          entries.last.toDiagnosisResult();
    }

    return getHistoryByKind(kind, ownerUserId: ownerId);
  }

  @override
  List<DiagnosisItem> getHistory(
    String type, {
    String? userId,
    String? ownerUserId,
  }) {
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    final bucket = _bucketKey(ownerId, type);
    final items = _itemsByBucket[bucket] ?? const <DiagnosisItem>[];
    return items.reversed.toList(growable: false);
  }

  @override
  DiagnosisItem getLatest(
    String type, {
    String? userId,
    String? ownerUserId,
  }) {
    final items = getHistory(type, userId: userId, ownerUserId: ownerUserId);
    if (items.isEmpty) {
      final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
      throw StateError('No history items for type=$type and user=$ownerId');
    }
    return items.first;
  }

  @override
  void addItem(
    String type,
    DiagnosisItem item, {
    String? userId,
    String? ownerUserId,
  }) {
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    final bucket = _bucketKey(ownerId, type);
    final items = _itemsByBucket.putIfAbsent(bucket, () => <DiagnosisItem>[]);
    items.removeWhere((existing) => existing.id == item.id);
    items.add(item);
  }

  @override
  Future<void> deleteItem(
    String type,
    String itemId, {
    String? userId,
    String? ownerUserId,
  }) async {
    final normalizedId = itemId.trim();
    if (normalizedId.isEmpty) return;

    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    final bucket = _bucketKey(ownerId, type);
    final items = _itemsByBucket[bucket];
    if (items == null || items.isEmpty) return;

    items.removeWhere((item) => item.id == normalizedId);
    _itemResults.remove(_itemResultKey(ownerId, type, normalizedId));

    if (items.isEmpty) {
      _itemsByBucket.remove(bucket);
      _lastResults.remove(_lastResultKey(ownerId, type));
      return;
    }

    final latest = items.last;
    final latestResult = _itemResults[_itemResultKey(ownerId, type, latest.id)];
    if (latestResult != null) {
      _lastResults[_lastResultKey(ownerId, type)] = latestResult;
    }
  }

  @override
  DiagnosisResult? getLastResult(
    String type, {
    String? userId,
    String? ownerUserId,
  }) {
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    return _lastResults[_lastResultKey(ownerId, type)];
  }

  @override
  void setLastResult(
    String type,
    DiagnosisResult result, {
    String? userId,
    String? ownerUserId,
  }) {
    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    _lastResults[_lastResultKey(ownerId, type)] = result;
  }

  @override
  DiagnosisResult? getResultForItem(
    String type,
    String itemId, {
    String? userId,
    String? ownerUserId,
  }) {
    final normalizedId = itemId.trim();
    if (normalizedId.isEmpty) return null;

    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    return _itemResults[_itemResultKey(ownerId, type, normalizedId)];
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
    if (normalizedId.isEmpty) return;

    final ownerId = _resolveUserId(userId, ownerUserId: ownerUserId);
    _itemResults[_itemResultKey(ownerId, type, normalizedId)] = result;
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

  String _bucketKey(String ownerId, String type) => '${ownerId}::$type';

  String _lastResultKey(String ownerId, String type) => '${ownerId}::$type::last';

  String _itemResultKey(String ownerId, String type, String itemId) =>
      '${ownerId}::$type::item::${itemId.trim()}';

  void _clearStoredResults(String ownerId, String type) {
    _lastResults.remove(_lastResultKey(ownerId, type));
    final prefix = '${ownerId}::$type::item::';
    final keys = _itemResults.keys
        .where((key) => key.startsWith(prefix))
        .toList(growable: false);
    for (final key in keys) {
      _itemResults.remove(key);
    }
  }
}
