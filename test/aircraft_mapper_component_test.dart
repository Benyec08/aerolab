import 'package:flutter_test/flutter_test.dart';

import 'package:aerolab/data/entities/aircraft_entity.dart';
import 'package:aerolab/data/mappers/aircraft_mapper.dart';
import 'package:aerolab/features/analysis/models/aircraft.dart';

void main() {
  group('AircraftMapper component integration', () {
    test('maps component identifiers from entity to model', () {
      final now = DateTime(2026, 7, 18, 20, 0);

      final entity = AircraftEntity(
        id: 'aircraft-001',
        name: 'Component Test Aircraft',
        type: 'Sabit Kanat',
        weightKg: 5.2,
        wingAreaM2: 1.4,
        wingSpanM: 2.6,
        motorCount: 1,
        motorPowerW: 1200,
        propellerDiameterInch: 15,
        batteryCapacityMah: 12000,
        batteryVoltageV: 22.2,
        batteryType: 'LiPo',
        batteryCellCount: 6,
        batteryDescription: '6S LiPo',
        createdAt: now,
        updatedAt: now,
        cruiseSpeedMs: 21,
        zeroLiftDragCoefficient: 0.032,
        maxLiftCoefficient: 1.5,
        oswaldEfficiencyFactor: 0.82,
        escEfficiency: 0.95,
        motorEfficiency: 0.88,
        continuousMotorPowerW: 1000,
        maximumMotorPowerW: 1400,
        cellInternalResistanceMilliOhm: 4.0,
        motorComponentId: 'motor-001',
        propellerComponentId: 'propeller-001',
        batteryComponentId: 'battery-001',
        escComponentId: 'esc-001',
        motorPropellerCombinationId: 'combination-001',
      );

      final model = AircraftMapper.toModel(entity);

      expect(model.motorComponentId, 'motor-001');
      expect(model.propellerComponentId, 'propeller-001');
      expect(model.batteryComponentId, 'battery-001');
      expect(model.escComponentId, 'esc-001');
      expect(model.motorPropellerCombinationId, 'combination-001');
      expect(model.usesComponentDatabase, isTrue);
      expect(model.usesManualComponentInputs, isFalse);
    });

    test('maps component identifiers from model to entity', () {
      final model = Aircraft(
        name: 'Mapped Component Aircraft',
        type: 'Drone',
        weightKg: 3.8,
        wingAreaM2: 0,
        wingSpanM: 0,
        motorCount: 4,
        motorPowerW: 2400,
        propellerDiameterInch: 14,
        batteryCapacityMah: 16000,
        batteryVoltageV: 22.2,
        batteryType: 'LiPo',
        batteryCellCount: 6,
        cellInternalResistanceMilliOhm: 3.8,
        cruiseSpeedMs: 15,
        escEfficiency: 0.96,
        motorEfficiency: 0.89,
        continuousMotorPowerW: 2200,
        maximumMotorPowerW: 2800,
        motorComponentId: 'motor-quad-001',
        propellerComponentId: 'propeller-quad-001',
        batteryComponentId: 'battery-quad-001',
        escComponentId: 'esc-quad-001',
        motorPropellerCombinationId: 'combination-quad-001',
      );

      final entity = AircraftMapper.toEntity(
        model,
        id: 'entity-001',
        batteryDescription: 'Selected database battery',
        createdAt: DateTime(2026, 7, 18),
      );

      expect(entity.id, 'entity-001');
      expect(entity.motorComponentId, 'motor-quad-001');
      expect(entity.propellerComponentId, 'propeller-quad-001');
      expect(entity.batteryComponentId, 'battery-quad-001');
      expect(entity.escComponentId, 'esc-quad-001');
      expect(entity.motorPropellerCombinationId, 'combination-quad-001');
    });

    test('preserves all manual engineering values', () {
      final original = Aircraft(
        name: 'Manual Aircraft',
        type: 'VTOL',
        weightKg: 7.4,
        wingAreaM2: 1.8,
        wingSpanM: 3.0,
        motorCount: 4,
        motorPowerW: 3600,
        propellerDiameterInch: 16,
        batteryCapacityMah: 18000,
        batteryVoltageV: 22.2,
        batteryType: 'Li-Ion',
        batteryCellCount: 6,
        cellInternalResistanceMilliOhm: 17.5,
        cruiseSpeedMs: 23,
        zeroLiftDragCoefficient: 0.034,
        maxLiftCoefficient: 1.55,
        oswaldEfficiencyFactor: 0.84,
        escEfficiency: 0.94,
        motorEfficiency: 0.87,
        continuousMotorPowerW: 3200,
        maximumMotorPowerW: 4200,
      );

      final entity = AircraftMapper.toEntity(original);
      final restored = AircraftMapper.toModel(entity);

      expect(restored.name, original.name);
      expect(restored.type, original.type);
      expect(restored.weightKg, original.weightKg);
      expect(restored.wingAreaM2, original.wingAreaM2);
      expect(restored.wingSpanM, original.wingSpanM);
      expect(restored.motorCount, original.motorCount);
      expect(restored.motorPowerW, original.motorPowerW);
      expect(restored.propellerDiameterInch, original.propellerDiameterInch);
      expect(restored.batteryCapacityMah, original.batteryCapacityMah);
      expect(restored.batteryVoltageV, original.batteryVoltageV);
      expect(restored.batteryType, original.batteryType);
      expect(restored.batteryCellCount, original.batteryCellCount);
      expect(
        restored.cellInternalResistanceMilliOhm,
        original.cellInternalResistanceMilliOhm,
      );
      expect(restored.cruiseSpeedMs, original.cruiseSpeedMs);
      expect(
        restored.zeroLiftDragCoefficient,
        original.zeroLiftDragCoefficient,
      );
      expect(restored.maxLiftCoefficient, original.maxLiftCoefficient);
      expect(restored.oswaldEfficiencyFactor, original.oswaldEfficiencyFactor);
      expect(restored.escEfficiency, original.escEfficiency);
      expect(restored.motorEfficiency, original.motorEfficiency);
      expect(restored.continuousMotorPowerW, original.continuousMotorPowerW);
      expect(restored.maximumMotorPowerW, original.maximumMotorPowerW);
      expect(restored.usesManualComponentInputs, isTrue);
    });

    test('old-style entity without component IDs remains manual', () {
      final now = DateTime(2026, 7, 18);

      final entity = AircraftEntity(
        id: 'legacy-aircraft',
        name: 'Legacy Aircraft',
        type: 'Sabit Kanat',
        weightKg: 4.5,
        wingAreaM2: 1.2,
        wingSpanM: 2.4,
        motorCount: 1,
        motorPowerW: 900,
        propellerDiameterInch: 14,
        batteryCapacityMah: 10000,
        batteryVoltageV: 22.2,
        batteryType: 'LiPo',
        batteryCellCount: 6,
        batteryDescription: '',
        createdAt: now,
        updatedAt: now,
      );

      final model = AircraftMapper.toModel(entity);

      expect(model.motorComponentId, isNull);
      expect(model.propellerComponentId, isNull);
      expect(model.batteryComponentId, isNull);
      expect(model.escComponentId, isNull);
      expect(model.motorPropellerCombinationId, isNull);
      expect(model.usesComponentDatabase, isFalse);
      expect(model.usesManualComponentInputs, isTrue);
    });

    test('entity map conversion preserves nullable component IDs', () {
      final now = DateTime(2026, 7, 18);

      final entity = AircraftEntity(
        id: 'map-aircraft',
        name: 'Map Aircraft',
        type: 'Drone',
        weightKg: 2.8,
        wingAreaM2: 0,
        wingSpanM: 0,
        motorCount: 4,
        motorPowerW: 1800,
        propellerDiameterInch: 12,
        batteryCapacityMah: 10000,
        batteryVoltageV: 14.8,
        batteryType: 'LiPo',
        batteryCellCount: 4,
        batteryDescription: '',
        createdAt: now,
        updatedAt: now,
        motorComponentId: 'motor-map',
        propellerComponentId: 'propeller-map',
        escComponentId: 'esc-map',
      );

      final restored = AircraftEntity.fromMap(entity.toMap());

      expect(restored.motorComponentId, 'motor-map');
      expect(restored.propellerComponentId, 'propeller-map');
      expect(restored.batteryComponentId, isNull);
      expect(restored.escComponentId, 'esc-map');
      expect(restored.motorPropellerCombinationId, isNull);
    });
  });
}
