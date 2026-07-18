import 'package:flutter_test/flutter_test.dart';

import 'package:aerolab/features/components/models/battery_component.dart';
import 'package:aerolab/features/components/models/esc_component.dart';
import 'package:aerolab/features/components/models/motor_component.dart';
import 'package:aerolab/features/components/models/motor_propeller_combination.dart';
import 'package:aerolab/features/components/models/propeller_component.dart';

void main() {
  group('MotorComponent', () {
    test(
      'valid motor supports expected voltage, cell and propeller ranges',
      () {
        final motor = MotorComponent(
          id: 'motor-001',
          manufacturer: 'Test Motors',
          model: 'TM 500',
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

        expect(motor.displayName, 'Test Motors TM 500');
        expect(motor.supportsVoltage(22.2), isTrue);
        expect(motor.supportsVoltage(29.6), isFalse);
        expect(motor.supportsCellCount(6), isTrue);
        expect(motor.supportsCellCount(8), isFalse);
        expect(motor.supportsPropellerDiameter(15), isTrue);
        expect(motor.supportsPropellerDiameter(18), isFalse);
      },
    );

    test('invalid continuous power above maximum power throws', () {
      expect(
        () => MotorComponent(
          id: 'motor-invalid',
          manufacturer: 'Test Motors',
          model: 'Invalid',
          kvRating: 500,
          minimumVoltageV: 14.8,
          maximumVoltageV: 25.2,
          continuousPowerW: 1300,
          maximumPowerW: 1200,
          continuousCurrentA: 40,
          maximumCurrentA: 55,
          efficiency: 0.88,
          weightG: 210,
          minimumRecommendedPropellerDiameterInch: 13,
          maximumRecommendedPropellerDiameterInch: 16,
          minimumRecommendedCellCount: 4,
          maximumRecommendedCellCount: 6,
        ),
        throwsArgumentError,
      );
    });
  });

  group('PropellerComponent', () {
    test('calculates disk area and validates motor KV', () {
      final propeller = PropellerComponent(
        id: 'prop-001',
        manufacturer: 'Test Props',
        model: 'TP 15x6',
        diameterInch: 15,
        pitchInch: 6,
        bladeCount: 2,
        material: 'Carbon Fiber',
        weightG: 32,
        minimumRecommendedKv: 400,
        maximumRecommendedKv: 700,
        minimumRecommendedVoltageV: 14.8,
        maximumRecommendedVoltageV: 25.2,
      );

      expect(propeller.displayName, 'Test Props TP 15x6 15.0x6.0');
      expect(propeller.diskAreaM2, closeTo(0.1140, 0.001));
      expect(propeller.supportsMotorKv(500), isTrue);
      expect(propeller.supportsMotorKv(900), isFalse);
      expect(propeller.supportsVoltage(22.2), isTrue);
    });

    test('invalid blade count throws', () {
      expect(
        () => PropellerComponent(
          id: 'prop-invalid',
          manufacturer: 'Test Props',
          model: 'Invalid',
          diameterInch: 15,
          pitchInch: 6,
          bladeCount: 1,
          material: 'Plastic',
          weightG: 30,
          minimumRecommendedKv: 400,
          maximumRecommendedKv: 700,
          minimumRecommendedVoltageV: 14.8,
          maximumRecommendedVoltageV: 25.2,
        ),
        throwsArgumentError,
      );
    });
  });

  group('BatteryComponent', () {
    test('calculates energy, current limits and pack resistance', () {
      final battery = BatteryComponent(
        id: 'battery-001',
        manufacturer: 'Test Power',
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

      expect(battery.capacityAh, 12);
      expect(battery.nominalEnergyWh, closeTo(266.4, 0.001));
      expect(battery.maximumContinuousCurrentA, 240);
      expect(battery.maximumBurstCurrentA, 360);
      expect(battery.packInternalResistanceOhm, closeTo(0.024, 0.0001));
      expect(battery.nominalCellVoltageV, closeTo(3.7, 0.001));
      expect(battery.supportsContinuousCurrent(200), isTrue);
      expect(battery.supportsContinuousCurrent(260), isFalse);
      expect(
        battery.supportsRequiredPower(requiredPowerW: 2200, loadedVoltageV: 22),
        isTrue,
      );
    });

    test('continuous C-rate above burst C-rate throws', () {
      expect(
        () => BatteryComponent(
          id: 'battery-invalid',
          manufacturer: 'Test Power',
          model: 'Invalid',
          chemistry: 'LiPo',
          cellCount: 6,
          capacityMah: 12000,
          nominalVoltageV: 22.2,
          continuousCRate: 40,
          burstCRate: 30,
          cellInternalResistanceMilliOhm: 4,
          weightG: 1450,
        ),
        throwsArgumentError,
      );
    });
  });

  group('EscComponent', () {
    test('validates current and supported cell ranges', () {
      final esc = EscComponent(
        id: 'esc-001',
        manufacturer: 'Test ESC',
        model: 'TE 80A',
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

      expect(esc.displayName, 'Test ESC TE 80A');
      expect(esc.supportsCellCount(6), isTrue);
      expect(esc.supportsCellCount(8), isFalse);
      expect(esc.supportsContinuousCurrent(70), isTrue);
      expect(esc.supportsContinuousCurrent(90), isFalse);
      expect(esc.supportsBurstCurrent(95), isTrue);
      expect(esc.continuousCurrentReserveA(70), 10);
      expect(esc.burstCurrentReserveA(95), 5);
    });

    test('ESC without BEC rejects non-zero BEC values', () {
      expect(
        () => EscComponent(
          id: 'esc-invalid',
          manufacturer: 'Test ESC',
          model: 'Invalid',
          continuousCurrentA: 80,
          burstCurrentA: 100,
          minimumSupportedCellCount: 3,
          maximumSupportedCellCount: 6,
          efficiency: 0.95,
          weightG: 95,
          hasBec: false,
          becVoltageV: 5,
          becCurrentA: 5,
        ),
        throwsArgumentError,
      );
    });
  });

  group('MotorPropellerCombination', () {
    test('reports maximum values and finds throttle points', () {
      final combination = MotorPropellerCombination(
        id: 'combo-001',
        motorComponentId: 'motor-001',
        propellerComponentId: 'prop-001',
        dataSource: 'Manufacturer test table',
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
            throttlePercent: 75,
            currentA: 31,
            electricalPowerW: 688.2,
            thrustN: 29,
            rpm: 6700,
            efficiencyGramPerWatt: 4.30,
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

      expect(combination.maximumThrustN, 41);
      expect(combination.maximumCurrentA, 48);
      expect(combination.maximumElectricalPowerW, 1065.6);
      expect(combination.findExactThrottle(75)?.thrustN, 29);
      expect(combination.findExactThrottle(60), isNull);
      expect(combination.nearestThrottle(70).throttlePercent, 75);
      expect(combination.maximumThrottlePoint.throttlePercent, 100);
    });

    test('rejects performance points with non-increasing throttle', () {
      expect(
        () => MotorPropellerCombination(
          id: 'combo-invalid',
          motorComponentId: 'motor-001',
          propellerComponentId: 'prop-001',
          dataSource: 'Test source',
          testDate: '2026-07-18',
          testConditions: 'Sea level',
          performancePoints: [
            MotorPropellerPerformancePoint(
              voltageV: 22.2,
              throttlePercent: 75,
              currentA: 30,
              electricalPowerW: 666,
              thrustN: 28,
              rpm: 6600,
              efficiencyGramPerWatt: 4.2,
            ),
            MotorPropellerPerformancePoint(
              voltageV: 22.2,
              throttlePercent: 50,
              currentA: 18,
              electricalPowerW: 399.6,
              thrustN: 18,
              rpm: 5200,
              efficiencyGramPerWatt: 4.59,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });
  });
}
