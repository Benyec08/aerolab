// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aircraft_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AircraftEntityAdapter extends TypeAdapter<AircraftEntity> {
  @override
  final typeId = 0;

  @override
  AircraftEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AircraftEntity(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      weightKg: (fields[3] as num).toDouble(),
      wingAreaM2: (fields[4] as num).toDouble(),
      wingSpanM: (fields[5] as num).toDouble(),
      motorCount: (fields[6] as num).toInt(),
      motorPowerW: (fields[7] as num).toDouble(),
      propellerDiameterInch: (fields[8] as num).toDouble(),
      batteryCapacityMah: (fields[9] as num).toDouble(),
      batteryVoltageV: (fields[10] as num).toDouble(),
      batteryType: fields[11] as String,
      batteryCellCount: (fields[12] as num).toInt(),
      batteryDescription: fields[13] as String,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
      cruiseSpeedMs: fields[16] == null ? 15.0 : (fields[16] as num).toDouble(),
      zeroLiftDragCoefficient: fields[17] == null
          ? 0.03
          : (fields[17] as num).toDouble(),
      maxLiftCoefficient: fields[18] == null
          ? 1.4
          : (fields[18] as num).toDouble(),
      oswaldEfficiencyFactor: fields[19] == null
          ? 0.8
          : (fields[19] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, AircraftEntity obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.weightKg)
      ..writeByte(4)
      ..write(obj.wingAreaM2)
      ..writeByte(5)
      ..write(obj.wingSpanM)
      ..writeByte(6)
      ..write(obj.motorCount)
      ..writeByte(7)
      ..write(obj.motorPowerW)
      ..writeByte(8)
      ..write(obj.propellerDiameterInch)
      ..writeByte(9)
      ..write(obj.batteryCapacityMah)
      ..writeByte(10)
      ..write(obj.batteryVoltageV)
      ..writeByte(11)
      ..write(obj.batteryType)
      ..writeByte(12)
      ..write(obj.batteryCellCount)
      ..writeByte(13)
      ..write(obj.batteryDescription)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.cruiseSpeedMs)
      ..writeByte(17)
      ..write(obj.zeroLiftDragCoefficient)
      ..writeByte(18)
      ..write(obj.maxLiftCoefficient)
      ..writeByte(19)
      ..write(obj.oswaldEfficiencyFactor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AircraftEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
