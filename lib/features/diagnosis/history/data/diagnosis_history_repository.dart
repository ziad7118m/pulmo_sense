import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/diagnosis_result.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/diagnosis_kind.dart';

abstract class DiagnosisHistoryRepository {
  List<DiagnosisItem> getHistory(
    String type, {
    String? userId,
    String? ownerUserId,
  });

  DiagnosisItem getLatest(
    String type, {
    String? userId,
    String? ownerUserId,
  });

  void addItem(
    String type,
    DiagnosisItem item, {
    String? userId,
    String? ownerUserId,
  });

  Future<void> deleteItem(
    String type,
    String itemId, {
    String? userId,
    String? ownerUserId,
  });

  DiagnosisResult? getLastResult(
    String type, {
    String? userId,
    String? ownerUserId,
  });

  void setLastResult(
    String type,
    DiagnosisResult result, {
    String? userId,
    String? ownerUserId,
  });

  DiagnosisResult? getResultForItem(
    String type,
    String itemId, {
    String? userId,
    String? ownerUserId,
  });

  void setResultForItem(
    String type,
    String itemId,
    DiagnosisResult result, {
    String? userId,
    String? ownerUserId,
  });

  bool supportsRemoteSync(DiagnosisKind kind) => false;

  Future<List<DiagnosisItem>> syncRemoteHistoryByKind(
    DiagnosisKind kind, {
    String? userId,
    String? ownerUserId,
  }) async => getHistoryByKind(
        kind,
        userId: _normalizeUserId(userId, ownerUserId),
      );

  String? _normalizeUserId(String? userId, String? ownerUserId) =>
      (ownerUserId ?? userId)?.trim().isEmpty == true ? null : (ownerUserId ?? userId);

  List<DiagnosisItem> getHistoryByKind(
    DiagnosisKind kind, {
    String? userId,
    String? ownerUserId,
  }) => getHistory(
        kind.storageKey,
        userId: _normalizeUserId(userId, ownerUserId),
      );

  List<DiagnosisItem> getHistoryByKindForUser(
    DiagnosisKind kind,
    String userId,
  ) => getHistoryByKind(kind, userId: userId);

  DiagnosisItem getLatestByKind(
    DiagnosisKind kind, {
    String? userId,
    String? ownerUserId,
  }) => getLatest(
        kind.storageKey,
        userId: _normalizeUserId(userId, ownerUserId),
      );

  DiagnosisItem getLatestByKindForUser(
    DiagnosisKind kind,
    String userId,
  ) => getLatestByKind(kind, userId: userId);

  void addItemByKind(
    DiagnosisKind kind,
    DiagnosisItem item, {
    String? userId,
    String? ownerUserId,
  }) => addItem(
        kind.storageKey,
        item,
        userId: _normalizeUserId(userId, ownerUserId),
      );

  void addItemByKindForUser(
    DiagnosisKind kind,
    DiagnosisItem item,
    String userId,
  ) => addItemByKind(kind, item, userId: userId);

  Future<void> deleteItemByKind(
    DiagnosisKind kind,
    String itemId, {
    String? userId,
    String? ownerUserId,
  }) => deleteItem(
        kind.storageKey,
        itemId,
        userId: _normalizeUserId(userId, ownerUserId),
      );

  Future<void> deleteItemByKindForUser(
    DiagnosisKind kind,
    String itemId,
    String userId,
  ) => deleteItemByKind(kind, itemId, userId: userId);

  DiagnosisResult? getLastResultByKind(
    DiagnosisKind kind, {
    String? userId,
    String? ownerUserId,
  }) => getLastResult(
        kind.storageKey,
        userId: _normalizeUserId(userId, ownerUserId),
      );

  DiagnosisResult? getLastResultByKindForUser(
    DiagnosisKind kind,
    String userId,
  ) => getLastResultByKind(kind, userId: userId);

  void setLastResultByKind(
    DiagnosisKind kind,
    DiagnosisResult result, {
    String? userId,
    String? ownerUserId,
  }) => setLastResult(
        kind.storageKey,
        result,
        userId: _normalizeUserId(userId, ownerUserId),
      );

  void setLastResultByKindForUser(
    DiagnosisKind kind,
    DiagnosisResult result,
    String userId,
  ) => setLastResultByKind(kind, result, userId: userId);

  DiagnosisResult? getResultForItemByKind(
    DiagnosisKind kind,
    String itemId, {
    String? userId,
    String? ownerUserId,
  }) => getResultForItem(
        kind.storageKey,
        itemId,
        userId: _normalizeUserId(userId, ownerUserId),
      );

  DiagnosisResult? getResultForItemByKindForUser(
    DiagnosisKind kind,
    String itemId,
    String userId,
  ) => getResultForItemByKind(kind, itemId, userId: userId);

  void setResultForItemByKind(
    DiagnosisKind kind,
    String itemId,
    DiagnosisResult result, {
    String? userId,
    String? ownerUserId,
  }) => setResultForItem(
        kind.storageKey,
        itemId,
        result,
        userId: _normalizeUserId(userId, ownerUserId),
      );

  void setResultForItemByKindForUser(
    DiagnosisKind kind,
    String itemId,
    DiagnosisResult result,
    String userId,
  ) => setResultForItemByKind(kind, itemId, result, userId: userId);
}
