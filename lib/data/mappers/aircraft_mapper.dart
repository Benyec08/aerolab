import '../../features/analysis/models/aircraft.dart';
import '../entities/aircraft_entity.dart';

class AircraftMapper {
  AircraftMapper._();

  static Aircraft toModel(AircraftEntity entity) {
    return Aircraft(
      name: entity.name,
      type: entity.type,
      weightKg: entity.weightKg,
      wingAreaM2: entity.wingAreaM2,
      wingSpanM: entity.wingSpanM,
      motorCount: entity.motorCount,
      motorPowerW: entity.motorPowerW,
      propellerDiameterInch: entity.propellerDiameterInch,
      batteryCapacityMah: entity.batteryCapacityMah,
      batteryVoltageV: entity.batteryVoltageV,
      batteryType: entity.batteryType,
      batteryCellCount: entity.batteryCellCount,
      motorComponentId: entity.motorComponentId,
      propellerComponentId: entity.propellerComponentId,
      batteryComponentId: entity.batteryComponentId,
      escComponentId: entity.escComponentId,
      motorPropellerCombinationId: entity.motorPropellerCombinationId,
      cellInternalResistanceMilliOhm: entity.cellInternalResistanceMilliOhm > 0
          ? entity.cellInternalResistanceMilliOhm
          : null,
      cruiseSpeedMs: entity.cruiseSpeedMs,
      zeroLiftDragCoefficient: entity.zeroLiftDragCoefficient,
      maxLiftCoefficient: entity.maxLiftCoefficient,
      oswaldEfficiencyFactor: entity.oswaldEfficiencyFactor,
      escEfficiency: entity.escEfficiency,
      motorEfficiency: entity.motorEfficiency,
      continuousMotorPowerW: entity.continuousMotorPowerW,
      maximumMotorPowerW: entity.maximumMotorPowerW,
    );
  }

  static AircraftEntity toEntity(
    Aircraft model, {
    String? id,
    String batteryDescription = '',
    DateTime? createdAt,
  }) {
    final now = DateTime.now();

    return AircraftEntity(
      id: id ?? now.microsecondsSinceEpoch.toString(),
      name: model.name,
      type: model.type,
      weightKg: model.weightKg,
      wingAreaM2: model.wingAreaM2,
      wingSpanM: model.wingSpanM,
      motorCount: model.motorCount,
      motorPowerW: model.motorPowerW,
      propellerDiameterInch: model.propellerDiameterInch,
      batteryCapacityMah: model.batteryCapacityMah,
      batteryVoltageV: model.batteryVoltageV,
      batteryType: model.batteryType,
      batteryCellCount: model.batteryCellCount,
      batteryDescription: batteryDescription,
      createdAt: createdAt ?? now,
      updatedAt: now,
      cruiseSpeedMs: model.cruiseSpeedMs,
      zeroLiftDragCoefficient: model.zeroLiftDragCoefficient,
      maxLiftCoefficient: model.maxLiftCoefficient,
      oswaldEfficiencyFactor: model.oswaldEfficiencyFactor,
      escEfficiency: model.escEfficiency,
      motorEfficiency: model.motorEfficiency,
      continuousMotorPowerW: model.continuousMotorPowerW,
      maximumMotorPowerW: model.maximumMotorPowerW,
      cellInternalResistanceMilliOhm: model.cellInternalResistanceMilliOhm,
      motorComponentId: model.motorComponentId,
      propellerComponentId: model.propellerComponentId,
      batteryComponentId: model.batteryComponentId,
      escComponentId: model.escComponentId,
      motorPropellerCombinationId: model.motorPropellerCombinationId,
    );
  }
}
