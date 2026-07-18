import 'package:flutter_test/flutter_test.dart';

import 'package:aerolab/features/components/models/battery_component.dart';
import 'package:aerolab/features/components/models/component_compatibility_result.dart';
import 'package:aerolab/features/components/models/esc_component.dart';
import 'package:aerolab/features/components/models/motor_component.dart';
import 'package:aerolab/features/components/models/motor_propeller_combination.dart';
import 'package:aerolab/features/components/models/propeller_component.dart';
import 'package:aerolab/features/components/services/component_compatibility_service.dart';

void main() {
  const service = ComponentCompatibilityService();

  final motor = MotorComponent(
    id: 'motor-001',
    manufacturer: 'Test Motor',
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

  final propeller = PropellerComponent(
    id: 'prop-001',
    manufacturer: 'Test Propeller',
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
    rotationDirection: 'CW/CCW',
  );

  final battery = BatteryComponent(
    id: 'battery-001',
    manufacturer: 'Test Battery',
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

  final combination = MotorPropellerCombination(
    id: 'combination-001',
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
        throttlePercent: 100,
        currentA: 48,
        electricalPowerW: 1065.6,
        thrustN: 41,
        rpm: 8100,
        efficiencyGramPerWatt: 3.92,
      ),
    ],
  );

  group('ComponentCompatibilityService', () {
    test('returns fully compatible result for matching components', () {
      final result = service.evaluate(
        motor: motor,
        propeller: propeller,
        battery: battery,
        esc: esc,
        combination: combination,
      );

      expect(result.isCompatible, isTrue);
      expect(result.hasCriticalIssues, isFalse);
      expect(result.score, 100);
      expect(result.statusLabel, 'Uyumlu');
      expect(result.issues, isEmpty);
    });

    test('returns info issue when real test table is not selected', () {
      final result = service.evaluate(
        motor: motor,
        propeller: propeller,
        battery: battery,
        esc: esc,
      );

      expect(result.isCompatible, isTrue);
      expect(result.hasCriticalIssues, isFalse);
      expect(result.infoIssueCount, 1);
      expect(result.score, 98);
      expect(result.statusLabel, 'Uyumlu');
      expect(result.issues.single.code, 'real_test_table_not_selected');
    });

    test('reports critical motor and battery mismatches', () {
      final incompatibleBattery = BatteryComponent(
        id: 'battery-invalid',
        manufacturer: 'Test Battery',
        model: '8S 1000',
        chemistry: 'LiPo',
        cellCount: 8,
        capacityMah: 1000,
        nominalVoltageV: 29.6,
        continuousCRate: 1,
        burstCRate: 2,
        cellInternalResistanceMilliOhm: 8,
        weightG: 400,
      );

      final result = service.evaluate(
        motor: motor,
        propeller: propeller,
        battery: incompatibleBattery,
        esc: esc,
      );

      expect(result.isCompatible, isFalse);
      expect(result.hasCriticalIssues, isTrue);
      expect(result.criticalIssueCount, greaterThanOrEqualTo(4));
      expect(result.score, 0);
      expect(result.statusLabel, 'Uyumsuz');

      final codes = result.issues.map((issue) => issue.code).toSet();

      expect(codes, contains('motor_battery_voltage_mismatch'));
      expect(codes, contains('motor_battery_cell_mismatch'));
      expect(codes, contains('battery_continuous_current_insufficient'));
      expect(codes, contains('battery_burst_current_insufficient'));
      expect(codes, contains('esc_battery_cell_mismatch'));
    });

    test('reports critical motor and propeller mismatches', () {
      final incompatiblePropeller = PropellerComponent(
        id: 'prop-invalid',
        manufacturer: 'Test Propeller',
        model: 'TP 22x10',
        diameterInch: 22,
        pitchInch: 10,
        bladeCount: 2,
        material: 'Carbon Fiber',
        weightG: 90,
        minimumRecommendedKv: 100,
        maximumRecommendedKv: 300,
        minimumRecommendedVoltageV: 14.8,
        maximumRecommendedVoltageV: 25.2,
        rotationDirection: 'CW/CCW',
      );

      final result = service.evaluate(
        motor: motor,
        propeller: incompatiblePropeller,
        battery: battery,
        esc: esc,
      );

      expect(result.isCompatible, isFalse);
      expect(result.criticalIssueCount, 2);

      final codes = result.issues.map((issue) => issue.code).toSet();

      expect(codes, contains('motor_propeller_diameter_mismatch'));
      expect(codes, contains('propeller_motor_kv_mismatch'));
    });

    test('reports insufficient ESC current and low reserve', () {
      final insufficientEsc = EscComponent(
        id: 'esc-small',
        manufacturer: 'Test ESC',
        model: 'TE 45A',
        continuousCurrentA: 45,
        burstCurrentA: 46,
        minimumSupportedCellCount: 3,
        maximumSupportedCellCount: 6,
        efficiency: 0.94,
        weightG: 60,
        hasBec: false,
      );

      final result = service.evaluate(
        motor: motor,
        propeller: propeller,
        battery: battery,
        esc: insufficientEsc,
        combination: combination,
      );

      expect(result.isCompatible, isFalse);
      expect(result.hasCriticalIssues, isTrue);

      final codes = result.issues.map((issue) => issue.code).toSet();

      expect(codes, contains('esc_continuous_current_insufficient'));
      expect(codes, contains('esc_burst_current_insufficient'));
    });

    test('reports low ESC reserve as warning', () {
      final lowReserveEsc = EscComponent(
        id: 'esc-low-reserve',
        manufacturer: 'Test ESC',
        model: 'TE 52A',
        continuousCurrentA: 52,
        burstCurrentA: 60,
        minimumSupportedCellCount: 3,
        maximumSupportedCellCount: 6,
        efficiency: 0.94,
        weightG: 65,
        hasBec: false,
      );

      final result = service.evaluate(
        motor: motor,
        propeller: propeller,
        battery: battery,
        esc: lowReserveEsc,
        combination: combination,
      );

      expect(result.isCompatible, isTrue);
      expect(result.hasWarnings, isTrue);
      expect(result.warningIssueCount, 1);
      expect(result.score, 90);
      expect(result.statusLabel, 'Koşullu Uyumlu');
      expect(result.issues.single.code, 'esc_current_margin_low');
    });

    test('reports mismatched test table component identifiers', () {
      final mismatchedCombination = MotorPropellerCombination(
        id: 'combination-mismatch',
        motorComponentId: 'different-motor',
        propellerComponentId: 'different-propeller',
        dataSource: 'Test table',
        testDate: '2026-07-18',
        testConditions: 'Sea level',
        performancePoints: [
          MotorPropellerPerformancePoint(
            voltageV: 22.2,
            throttlePercent: 100,
            currentA: 40,
            electricalPowerW: 888,
            thrustN: 35,
            rpm: 7600,
            efficiencyGramPerWatt: 4,
          ),
        ],
      );

      final result = service.evaluate(
        motor: motor,
        propeller: propeller,
        battery: battery,
        esc: esc,
        combination: mismatchedCombination,
      );

      expect(result.isCompatible, isFalse);
      expect(result.criticalIssueCount, 2);

      final codes = result.issues.map((issue) => issue.code).toSet();

      expect(codes, contains('combination_motor_mismatch'));
      expect(codes, contains('combination_propeller_mismatch'));
    });

    test('reports test table voltage mismatch as warning', () {
      final differentVoltageCombination = MotorPropellerCombination(
        id: 'combination-voltage',
        motorComponentId: 'motor-001',
        propellerComponentId: 'prop-001',
        dataSource: 'Test table',
        testDate: '2026-07-18',
        testConditions: 'Sea level',
        performancePoints: [
          MotorPropellerPerformancePoint(
            voltageV: 14.8,
            throttlePercent: 100,
            currentA: 45,
            electricalPowerW: 666,
            thrustN: 28,
            rpm: 7000,
            efficiencyGramPerWatt: 4.28,
          ),
        ],
      );

      final result = service.evaluate(
        motor: motor,
        propeller: propeller,
        battery: battery,
        esc: esc,
        combination: differentVoltageCombination,
      );

      expect(result.isCompatible, isTrue);
      expect(result.hasWarnings, isTrue);
      expect(result.warningIssueCount, 1);
      expect(result.score, 90);
      expect(result.issues.single.code, 'combination_voltage_mismatch');
    });
  });

  group('ComponentCompatibilityResult', () {
    test('serializes and restores compatibility result', () {
      final original = ComponentCompatibilityResult(
        isCompatible: true,
        score: 90,
        issues: const [
          CompatibilityIssue(
            code: 'warning-code',
            title: 'Warning',
            message: 'Warning message',
            severity: CompatibilitySeverity.warning,
          ),
        ],
      );

      final restored = ComponentCompatibilityResult.fromMap(original.toMap());

      expect(restored.isCompatible, original.isCompatible);
      expect(restored.score, original.score);
      expect(restored.warningIssueCount, 1);
      expect(restored.statusLabel, 'Koşullu Uyumlu');
      expect(restored.issues.single.code, 'warning-code');
    });

    test('rejects score outside valid range', () {
      expect(
        () => ComponentCompatibilityResult(
          isCompatible: false,
          score: 101,
          issues: const [],
        ),
        throwsArgumentError,
      );
    });
  });
}
