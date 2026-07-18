import 'package:flutter_test/flutter_test.dart';

import 'package:aerolab/features/components/models/battery_component.dart';
import 'package:aerolab/features/components/models/esc_component.dart';
import 'package:aerolab/features/components/models/motor_component.dart';
import 'package:aerolab/features/components/models/motor_propeller_combination.dart';
import 'package:aerolab/features/components/models/propeller_component.dart';
import 'package:aerolab/features/components/repositories/battery_component_repository.dart';
import 'package:aerolab/features/components/repositories/esc_repository.dart';
import 'package:aerolab/features/components/repositories/motor_propeller_combination_repository.dart';
import 'package:aerolab/features/components/repositories/motor_repository.dart';
import 'package:aerolab/features/components/repositories/propeller_repository.dart';

void main() {
  final motorA = MotorComponent(
    id: 'motor-a',
    manufacturer: 'AeroDrive',
    model: 'AD 500',
    kvRating: 500,
    minimumVoltageV: 14.8,
    maximumVoltageV: 25.2,
    continuousPowerW: 900,
    maximumPowerW: 1200,
    continuousCurrentA: 40,
    maximumCurrentA: 55,
    efficiency: 0.88,
    weightG: 210,
    minimumRecommendedPropellerDiameterInch: 13,
    maximumRecommendedPropellerDiameterInch: 16,
    minimumRecommendedCellCount: 4,
    maximumRecommendedCellCount: 6,
  );

  final motorB = MotorComponent(
    id: 'motor-b',
    manufacturer: 'PowerLift',
    model: 'PL 900',
    kvRating: 900,
    minimumVoltageV: 11.1,
    maximumVoltageV: 16.8,
    continuousPowerW: 650,
    maximumPowerW: 850,
    continuousCurrentA: 35,
    maximumCurrentA: 45,
    efficiency: 0.85,
    weightG: 160,
    minimumRecommendedPropellerDiameterInch: 9,
    maximumRecommendedPropellerDiameterInch: 12,
    minimumRecommendedCellCount: 3,
    maximumRecommendedCellCount: 4,
  );

  final propellerA = PropellerComponent(
    id: 'prop-a',
    manufacturer: 'AeroProp',
    model: 'AP 15x6',
    diameterInch: 15,
    pitchInch: 6,
    bladeCount: 2,
    material: 'Carbon Fiber',
    weightG: 32,
    minimumRecommendedKv: 400,
    maximumRecommendedKv: 700,
    minimumRecommendedVoltageV: 14.8,
    maximumRecommendedVoltageV: 25.2,
    rotationDirection: 'CW/CCW',
  );

  final propellerB = PropellerComponent(
    id: 'prop-b',
    manufacturer: 'SpeedProp',
    model: 'SP 10x5',
    diameterInch: 10,
    pitchInch: 5,
    bladeCount: 3,
    material: 'Plastic',
    weightG: 24,
    minimumRecommendedKv: 750,
    maximumRecommendedKv: 1100,
    minimumRecommendedVoltageV: 11.1,
    maximumRecommendedVoltageV: 16.8,
    rotationDirection: 'CW',
  );

  final batteryA = BatteryComponent(
    id: 'battery-a',
    manufacturer: 'EnergyPack',
    model: '6S 12000',
    chemistry: 'LiPo',
    cellCount: 6,
    capacityMah: 12000,
    nominalVoltageV: 22.2,
    continuousCRate: 20,
    burstCRate: 30,
    cellInternalResistanceMilliOhm: 4,
    weightG: 1450,
  );

  final batteryB = BatteryComponent(
    id: 'battery-b',
    manufacturer: 'LongRange',
    model: '4S 8000',
    chemistry: 'Li-Ion',
    cellCount: 4,
    capacityMah: 8000,
    nominalVoltageV: 14.8,
    continuousCRate: 10,
    burstCRate: 15,
    cellInternalResistanceMilliOhm: 7,
    weightG: 900,
  );

  final escA = EscComponent(
    id: 'esc-a',
    manufacturer: 'AeroESC',
    model: 'AE 80A',
    continuousCurrentA: 80,
    burstCurrentA: 100,
    minimumSupportedCellCount: 3,
    maximumSupportedCellCount: 6,
    efficiency: 0.95,
    weightG: 95,
    hasBec: true,
    becVoltageV: 5,
    becCurrentA: 5,
  );

  final escB = EscComponent(
    id: 'esc-b',
    manufacturer: 'PowerESC',
    model: 'PE 50A',
    continuousCurrentA: 50,
    burstCurrentA: 65,
    minimumSupportedCellCount: 3,
    maximumSupportedCellCount: 4,
    efficiency: 0.92,
    weightG: 70,
    hasBec: false,
  );

  final combinationA = MotorPropellerCombination(
    id: 'combo-a',
    motorComponentId: 'motor-a',
    propellerComponentId: 'prop-a',
    dataSource: 'AeroDrive manufacturer test',
    testDate: '2026-07-18',
    testConditions: 'Sea level, 20 °C',
    performancePoints: [
      MotorPropellerPerformancePoint(
        voltageV: 22.2,
        throttlePercent: 50,
        currentA: 18,
        electricalPowerW: 399.6,
        thrustN: 18,
        rpm: 5200,
        efficiencyGramPerWatt: 4.59,
      ),
      MotorPropellerPerformancePoint(
        voltageV: 22.2,
        throttlePercent: 100,
        currentA: 48,
        electricalPowerW: 1065.6,
        thrustN: 41,
        rpm: 8100,
        efficiencyGramPerWatt: 3.92,
      ),
    ],
  );

  final combinationB = MotorPropellerCombination(
    id: 'combo-b',
    motorComponentId: 'motor-b',
    propellerComponentId: 'prop-b',
    dataSource: 'PowerLift bench test',
    testDate: '2026-07-18',
    testConditions: 'Sea level, 20 °C',
    performancePoints: [
      MotorPropellerPerformancePoint(
        voltageV: 14.8,
        throttlePercent: 50,
        currentA: 15,
        electricalPowerW: 222,
        thrustN: 10,
        rpm: 6800,
        efficiencyGramPerWatt: 4.59,
      ),
      MotorPropellerPerformancePoint(
        voltageV: 14.8,
        throttlePercent: 100,
        currentA: 38,
        electricalPowerW: 562.4,
        thrustN: 22,
        rpm: 10500,
        efficiencyGramPerWatt: 3.99,
      ),
    ],
  );

  group('MotorRepository', () {
    final repository = MotorRepository(initialMotors: [motorA, motorB]);

    test('finds, searches and filters motors', () {
      expect(repository.count, 2);
      expect(repository.findById('motor-a')?.model, 'AD 500');
      expect(repository.searchByModel('900'), hasLength(1));
      expect(repository.filterByManufacturer('aerodrive'), hasLength(1));
      expect(
        repository.filterByKvRange(minimumKv: 450, maximumKv: 550),
        hasLength(1),
      );
      expect(repository.filterByVoltage(22.2), hasLength(1));
      expect(repository.filterByCellCount(4), hasLength(2));
      expect(repository.filterByMinimumContinuousPower(800), hasLength(1));
      expect(repository.filterByPropellerDiameter(15), hasLength(1));
    });
  });

  group('PropellerRepository', () {
    final repository = PropellerRepository(
      initialPropellers: [propellerA, propellerB],
    );

    test('finds, searches and filters propellers', () {
      expect(repository.count, 2);
      expect(repository.findById('prop-b')?.model, 'SP 10x5');
      expect(repository.searchByModel('carbon'), hasLength(1));
      expect(
        repository.filterByDiameterRange(
          minimumDiameterInch: 14,
          maximumDiameterInch: 16,
        ),
        hasLength(1),
      );
      expect(repository.filterByBladeCount(3), hasLength(1));
      expect(repository.filterByMaterial('plastic'), hasLength(1));
      expect(repository.filterByMotorKv(500), hasLength(1));
      expect(repository.filterByVoltage(14.8), hasLength(2));
      expect(repository.filterByRotationDirection('CCW'), hasLength(1));
    });
  });

  group('BatteryComponentRepository', () {
    final repository = BatteryComponentRepository(
      initialBatteries: [batteryA, batteryB],
    );

    test('finds, searches and filters batteries', () {
      expect(repository.count, 2);
      expect(repository.findById('battery-a')?.cellCount, 6);
      expect(repository.searchByModel('li-ion'), hasLength(1));
      expect(repository.filterByChemistry('LIION'), hasLength(1));
      expect(repository.filterByCellCount(6), hasLength(1));
      expect(
        repository.filterByCapacityRange(
          minimumCapacityMah: 10000,
          maximumCapacityMah: 13000,
        ),
        hasLength(1),
      );
      expect(repository.filterByMinimumContinuousCurrent(100), hasLength(1));
      expect(repository.filterByMinimumEnergy(200), hasLength(1));
      expect(repository.filterByMaximumWeight(1000), hasLength(1));
      expect(
        repository.filterByRequiredPower(
          requiredPowerW: 2000,
          loadedVoltageV: 20,
        ),
        hasLength(1),
      );
    });
  });

  group('EscRepository', () {
    final repository = EscRepository(initialEscs: [escA, escB]);

    test('finds, searches and filters ESCs', () {
      expect(repository.count, 2);
      expect(repository.findById('esc-b')?.model, 'PE 50A');
      expect(repository.searchByModel('opto'), hasLength(1));
      expect(repository.filterByCellCount(6), hasLength(1));
      expect(repository.filterByMinimumContinuousCurrent(70), hasLength(1));
      expect(
        repository.filterByEfficiencyRange(
          minimumEfficiency: 0.94,
          maximumEfficiency: 0.96,
        ),
        hasLength(1),
      );
      expect(repository.filterByMaximumWeight(80), hasLength(1));
      expect(repository.filterByBecAvailability(true), hasLength(1));
      expect(repository.filterByMinimumBecCurrent(4), hasLength(1));
      expect(
        repository.filterByRequiredCurrent(
          continuousCurrentA: 60,
          burstCurrentA: 90,
        ),
        hasLength(1),
      );
    });
  });

  group('MotorPropellerCombinationRepository', () {
    final repository = MotorPropellerCombinationRepository(
      initialCombinations: [combinationA, combinationB],
    );

    test('finds, searches and filters combinations', () {
      expect(repository.count, 2);
      expect(repository.findById('combo-a')?.maximumThrustN, 41);
      expect(repository.searchByModel('bench'), hasLength(1));
      expect(repository.filterByMotorId('motor-a'), hasLength(1));
      expect(repository.filterByPropellerId('prop-b'), hasLength(1));
      expect(
        repository
            .findByMotorAndPropeller(
              motorComponentId: 'motor-a',
              propellerComponentId: 'prop-a',
            )
            ?.id,
        'combo-a',
      );
      expect(repository.filterByMinimumThrust(30), hasLength(1));
      expect(repository.filterByMaximumCurrent(40), hasLength(1));
      expect(repository.filterByMaximumPower(600), hasLength(1));
      expect(repository.filterByVoltage(22.2), hasLength(1));
      expect(repository.filterByDataSource('powerlift'), hasLength(1));
    });
  });

  group('Repository validation', () {
    test('invalid filters throw argument errors', () {
      final motorRepository = MotorRepository(initialMotors: [motorA]);
      final propellerRepository = PropellerRepository(
        initialPropellers: [propellerA],
      );
      final batteryRepository = BatteryComponentRepository(
        initialBatteries: [batteryA],
      );
      final escRepository = EscRepository(initialEscs: [escA]);

      expect(
        () => motorRepository.filterByKvRange(minimumKv: 700, maximumKv: 500),
        throwsArgumentError,
      );
      expect(
        () => propellerRepository.filterByBladeCount(1),
        throwsArgumentError,
      );
      expect(
        () => batteryRepository.filterByMaximumWeight(0),
        throwsArgumentError,
      );
      expect(
        () => escRepository.filterByRequiredCurrent(
          continuousCurrentA: 90,
          burstCurrentA: 70,
        ),
        throwsArgumentError,
      );
    });
  });
}
