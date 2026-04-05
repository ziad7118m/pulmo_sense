import 'package:hive/hive.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';

part 'diagnosis_item_entity.g.dart';

@HiveType(typeId: 1)
class DiagnosisItemEntity extends HiveObject {
  @HiveField(0)
  final String dateTime;

  @HiveField(1)
  final String diagnosis;

  @HiveField(2)
  final double percentage;

  @HiveField(3)
  final String? imagePath;

  @HiveField(4)
  final String? audioPath;

  @HiveField(5)
  final List<double>? waveSamples;

  @HiveField(6)
  final int? audioSourceType;

  @HiveField(7)
  final String userId;

  @HiveField(8)
  final String? createdByDoctorId;

  @HiveField(9)
  final String? createdByDoctorName;

  @HiveField(10)
  final String? targetPatientId;

  @HiveField(11)
  final String? targetPatientName;

  @HiveField(12)
  final String id;

  DiagnosisItemEntity({
    String? id,
    required this.dateTime,
    required this.diagnosis,
    required this.percentage,
    this.imagePath,
    this.audioPath,
    this.waveSamples,
    this.audioSourceType,
    this.userId = '',
    this.createdByDoctorId,
    this.createdByDoctorName,
    this.targetPatientId,
    this.targetPatientName,
  }) : id = (id != null && id.trim().isNotEmpty)
            ? id.trim()
            : legacyDiagnosisItemId(
                dateTime: dateTime,
                diagnosis: diagnosis,
                percentage: percentage,
                imagePath: imagePath,
                audioPath: audioPath,
                waveSamples: waveSamples,
              );

  DiagnosisItem toDomain() => DiagnosisItem(
        id: id,
        dateTime: dateTime,
        diagnosis: diagnosis,
        percentage: percentage,
        imagePath: imagePath,
        audioPath: audioPath,
        waveSamples: waveSamples,
        audioSourceType:
            audioSourceType == null ? null : AudioSourceTypeX.fromInt(audioSourceType!),
        createdByDoctorId: createdByDoctorId,
        createdByDoctorName: createdByDoctorName,
        targetPatientId: targetPatientId,
        targetPatientName: targetPatientName,
      );

  static DiagnosisItemEntity fromDomain(DiagnosisItem item) {
    return DiagnosisItemEntity(
      id: item.id,
      dateTime: item.dateTime,
      diagnosis: item.diagnosis,
      percentage: item.percentage,
      imagePath: item.imagePath,
      audioPath: item.audioPath,
      waveSamples: item.waveSamples,
      audioSourceType: item.audioSourceType?.toInt(),
      createdByDoctorId: item.createdByDoctorId,
      createdByDoctorName: item.createdByDoctorName,
      targetPatientId: item.targetPatientId,
      targetPatientName: item.targetPatientName,
    );
  }
}
