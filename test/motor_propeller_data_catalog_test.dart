import 'package:flutter_test/flutter_test.dart';

import 'package:aerolab/features/components/data/motor_propeller/motor_propeller_data_catalog.dart';
import 'package:aerolab/features/components/data/motor_propeller/tmotor_mn3510_kv360_p15x5cf_data.dart';
import 'package:aerolab/features/components/data/motor_propeller/tmotor_mn4014_kv400_p15x5cf_data.dart';
import 'package:aerolab/features/components/data/motor_propeller/tmotor_mn501s_kv240_p14x48_data.dart';
import 'package:aerolab/features/components/repositories/motor_propeller_combination_repository.dart';

void main() {
  group('MotorPropellerDataCatalog', () {
    test('contains all real motor-propeller combinations', () {
      final combinations = MotorPropellerDataCatalog.createAll();

      expect(combinations, hasLength(3));
      expect(MotorPropellerDataCatalog.combinationCount, 3);
      expect(MotorPropellerDataCatalog.performancePointCount, 30);
    });

    test('contains expected T-MOTOR combination identifiers', () {
      final combinationIds = MotorPropellerDataCatalog.createAll()
          .map((combination) => combination.id)
          .toSet();

      expect(
        combinationIds,
        contains(TMotorMn501sKv240P14x48Data.combinationId),
      );
      expect(
        combinationIds,
        contains(TMotorMn3510Kv360P15x5CfData.combinationId),
      );
      expect(
        combinationIds,
        contains(TMotorMn4014Kv400P15x5CfData.combinationId),
      );
    });

    test('finds combinations by ID, motor ID and propeller ID', () {
      final byId = MotorPropellerDataCatalog.findById(
        TMotorMn501sKv240P14x48Data.combinationId,
      );

      final byMotorId = MotorPropellerDataCatalog.findByMotorId(
        TMotorMn3510Kv360P15x5CfData.motorComponentId,
      );

      final byPropellerId = MotorPropellerDataCatalog.findByPropellerId(
        TMotorMn3510Kv360P15x5CfData.propellerComponentId,
      );

      expect(byId, isNotNull);
      expect(
        byId?.motorComponentId,
        TMotorMn501sKv240P14x48Data.motorComponentId,
      );
      expect(byMotorId, hasLength(1));
      expect(byPropellerId, hasLength(2));
    });

    test('returns null or empty lists for unknown identifiers', () {
      expect(MotorPropellerDataCatalog.findById('unknown-combination'), isNull);
      expect(MotorPropellerDataCatalog.findByMotorId('unknown-motor'), isEmpty);
      expect(
        MotorPropellerDataCatalog.findByPropellerId('unknown-propeller'),
        isEmpty,
      );
    });
  });

  group('Real performance tables', () {
    test('MN501-S table preserves expected range and maximum values', () {
      final combination = TMotorMn501sKv240P14x48Data.create();

      expect(combination.performancePoints, hasLength(20));
      expect(combination.minimumThrottlePoint.throttlePercent, 40);
      expect(combination.maximumThrottlePoint.throttlePercent, 100);
      expect(combination.maximumCurrentA, closeTo(18.52, 0.001));
      expect(combination.maximumElectricalPowerW, closeTo(899, 0.001));
      expect(combination.maximumThrustN, closeTo(38.157675, 0.001));
    });

    test('MN3510 table preserves expected maximum values', () {
      final combination = TMotorMn3510Kv360P15x5CfData.create();

      expect(combination.performancePoints, hasLength(5));
      expect(combination.maximumCurrentA, closeTo(6.8, 0.001));
      expect(combination.maximumElectricalPowerW, closeTo(100.64, 0.001));
      expect(combination.maximumThrustN, closeTo(9.80665, 0.001));
      expect(combination.maximumThrottlePoint.rpm, closeTo(4400, 0.001));
    });

    test('MN4014 table preserves expected maximum values', () {
      final combination = TMotorMn4014Kv400P15x5CfData.create();

      expect(combination.performancePoints, hasLength(5));
      expect(combination.maximumCurrentA, closeTo(18.7, 0.001));
      expect(combination.maximumElectricalPowerW, closeTo(415.14, 0.001));
      expect(combination.maximumThrustN, closeTo(25.6934, 0.001));
      expect(combination.maximumThrottlePoint.rpm, closeTo(6700, 0.001));
    });

    test('all performance tables use increasing throttle values', () {
      for (final combination in MotorPropellerDataCatalog.createAll()) {
        for (
          var index = 1;
          index < combination.performancePoints.length;
          index++
        ) {
          final previous = combination.performancePoints[index - 1];
          final current = combination.performancePoints[index];

          expect(
            current.throttlePercent,
            greaterThan(previous.throttlePercent),
          );
        }
      }
    });
  });

  group('MotorPropellerCombinationRepository integration', () {
    final repository = MotorPropellerCombinationRepository(
      initialCombinations: MotorPropellerDataCatalog.createAll(),
    );

    test('loads the catalog into the repository', () {
      expect(repository.count, 3);
      expect(repository.isNotEmpty, isTrue);
      expect(
        repository.containsId(TMotorMn4014Kv400P15x5CfData.combinationId),
        isTrue,
      );
    });

    test('filters real tables by motor, propeller and voltage', () {
      expect(
        repository.filterByMotorId(
          TMotorMn501sKv240P14x48Data.motorComponentId,
        ),
        hasLength(1),
      );

      expect(
        repository.filterByPropellerId(
          TMotorMn3510Kv360P15x5CfData.propellerComponentId,
        ),
        hasLength(2),
      );

      expect(repository.filterByVoltage(14.8), hasLength(1));
      expect(repository.filterByVoltage(22.2), hasLength(1));
      expect(repository.filterByVoltage(48.5), hasLength(1));
    });

    test('filters real tables by performance limits', () {
      expect(repository.filterByMinimumThrust(30), hasLength(1));
      expect(repository.filterByMaximumCurrent(10), hasLength(1));
      expect(repository.filterByMaximumPower(500), hasLength(2));
    });
  });
}
