// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_history_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalysisHistoryEntityAdapter extends TypeAdapter<AnalysisHistoryEntity> {
  @override
  final typeId = 1;

  @override
  AnalysisHistoryEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisHistoryEntity(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      aircraftName: fields[2] as String,
      aircraftType: fields[3] as String,
      aircraftDataJson: fields[4] as String,
      environmentDataJson: fields[5] as String,
      resultDataJson: fields[6] as String,
      dataVersion: fields[7] == null ? 1 : (fields[7] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisHistoryEntity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.aircraftName)
      ..writeByte(3)
      ..write(obj.aircraftType)
      ..writeByte(4)
      ..write(obj.aircraftDataJson)
      ..writeByte(5)
      ..write(obj.environmentDataJson)
      ..writeByte(6)
      ..write(obj.resultDataJson)
      ..writeByte(7)
      ..write(obj.dataVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisHistoryEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
