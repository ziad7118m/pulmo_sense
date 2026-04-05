// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis_item_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiagnosisItemEntityAdapter extends TypeAdapter<DiagnosisItemEntity> {
  @override
  final int typeId = 1;

  @override
  DiagnosisItemEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiagnosisItemEntity(
      id: fields[12] as String?,
      dateTime: fields[0] as String,
      diagnosis: fields[1] as String,
      percentage: fields[2] as double,
      imagePath: fields[3] as String?,
      audioPath: fields[4] as String?,
      waveSamples: (fields[5] as List?)?.cast<double>(),
      audioSourceType: fields[6] as int?,
      userId: (fields[7] as String?) ?? '',
      createdByDoctorId: fields[8] as String?,
      createdByDoctorName: fields[9] as String?,
      targetPatientId: fields[10] as String?,
      targetPatientName: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DiagnosisItemEntity obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.dateTime)
      ..writeByte(1)
      ..write(obj.diagnosis)
      ..writeByte(2)
      ..write(obj.percentage)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.audioPath)
      ..writeByte(5)
      ..write(obj.waveSamples)
      ..writeByte(6)
      ..write(obj.audioSourceType)
      ..writeByte(7)
      ..write(obj.userId)
      ..writeByte(8)
      ..write(obj.createdByDoctorId)
      ..writeByte(9)
      ..write(obj.createdByDoctorName)
      ..writeByte(10)
      ..write(obj.targetPatientId)
      ..writeByte(11)
      ..write(obj.targetPatientName)
      ..writeByte(12)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosisItemEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
