import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/environment.dart';
import 'package:aerolab/features/analysis/services/analysis_service.dart';
import 'package:aerolab/features/components/data/motor_propeller/tmotor_mn3510_kv360_p15x5cf_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const environment = Environment(
    altitudeM: 0.0,
    temperatureC: 15.0,
    pressureHpa: 1013.25,
    humidityPercent: 40.0,
    windSpeedKmh: 0.0,
    windDirection: 'Sakin',
  );

  Aircraft createAircraft({
    String? motorComponentId,
    String? propellerComponentId,
    String? motorPropellerCombinationId,
    double propellerDiameterInch = 15.0,
    double batteryVoltageV = 14.8,
    double maximumMotorPowerW = 100.64,
    int motorCount = 1,
    double weightKg = 1.5,
  }) {
    return Aircraft(
      name: 'Sprint 14E Test Aircraft',
      type: 'Sabit Kanat',
      weightKg: weightKg,
      wingAreaM2: 0.45,
      wingSpanM: 1.80,
      motorCount: motorCount,
      motorPowerW: 100.64 * motorCount,
      propellerDiameterInch: propellerDiameterInch,
      batteryCapacityMah: 5000.0,
      batteryVoltageV: batteryVoltageV,
      batteryType: 'LiPo',
      batteryCellCount: 4,
      motorComponentId: motorComponentId,
      propellerComponentId: propellerComponentId,
      motorPropellerCombinationId: motorPropellerCombinationId,
      cruiseSpeedMs: 15.0,
      zeroLiftDragCoefficient: 0.030,
      maxLiftCoefficient: 1.4,
      oswaldEfficiencyFactor: 0.80,
      escEfficiency: 0.95,
      motorEfficiency: 0.85,
      continuousMotorPowerW: 90.0 * motorCount,
      maximumMotorPowerW: maximumMotorPowerW * motorCount,
    );
  }

  group('AnalysisService Sprint 14E component integration', () {
    test('preserves manual analysis flow when no component is selected', () {
      final result = AnalysisService().analyze(createAircraft(), environment);

      expect(result.usesComponentDatabase, isFalse);
      expect(result.hasRealMotorPropellerData, isFalse);
      expect(result.motorComponentId, isNull);
      expect(result.propellerComponentId, isNull);
      expect(result.motorPropellerCombinationId, isNull);
      expect(result.componentDataSource, 'Manuel giriş');
      expect(result.componentCompatibilityScore, 100);
      expect(result.componentCompatibilityStatus, 'Manuel Giriş');
      expect(result.isComponentSelectionCompatible, isTrue);
      expect(result.realTestMaximumThrustPerMotorN, 0.0);
      expect(result.realTestTotalMaximumThrustN, 0.0);
    });

    test('copies real motor-propeller table values into result', () {
      final result = AnalysisService().analyze(
        createAircraft(
          motorComponentId: TMotorMn3510Kv360P15x5CfData.motorComponentId,
          propellerComponentId:
              TMotorMn3510Kv360P15x5CfData.propellerComponentId,
          motorPropellerCombinationId:
              TMotorMn3510Kv360P15x5CfData.combinationId,
        ),
        environment,
      );

      expect(result.usesComponentDatabase, isTrue);
      expect(result.hasRealMotorPropellerData, isTrue);
      expect(
        result.motorComponentId,
        TMotorMn3510Kv360P15x5CfData.motorComponentId,
      );
      expect(
        result.propellerComponentId,
        TMotorMn3510Kv360P15x5CfData.propellerComponentId,
      );
      expect(
        result.motorPropellerCombinationId,
        TMotorMn3510Kv360P15x5CfData.combinationId,
      );

      expect(result.realTestMaximumThrustPerMotorN, closeTo(9.806650, 1e-6));
      expect(result.realTestTotalMaximumThrustN, closeTo(9.806650, 1e-6));
      expect(result.realTestMaximumCurrentPerMotorA, closeTo(6.8, 1e-9));
      expect(result.realTestTotalMaximumCurrentA, closeTo(6.8, 1e-9));
      expect(result.realTestMaximumPowerPerMotorW, closeTo(100.64, 1e-9));
      expect(result.realTestTotalMaximumPowerW, closeTo(100.64, 1e-9));
      expect(result.realTestVoltageV, closeTo(14.8, 1e-9));
      expect(result.realTestThrustToWeight, closeTo(2 / 3, 1e-6));

      expect(result.componentCompatibilityScore, 100);
      expect(result.componentCompatibilityStatus, 'Uyumlu');
      expect(result.isComponentSelectionCompatible, isTrue);
      expect(result.componentDataSource, contains('T-MOTOR'));
      expect(result.componentTestConditions, contains('14.8 V'));
    });

    test('scales real test totals using motor count', () {
      final result = AnalysisService().analyze(
        createAircraft(
          motorComponentId: TMotorMn3510Kv360P15x5CfData.motorComponentId,
          propellerComponentId:
              TMotorMn3510Kv360P15x5CfData.propellerComponentId,
          motorPropellerCombinationId:
              TMotorMn3510Kv360P15x5CfData.combinationId,
          motorCount: 2,
          weightKg: 3.0,
        ),
        environment,
      );

      expect(result.realTestMaximumThrustPerMotorN, closeTo(9.806650, 1e-6));
      expect(result.realTestTotalMaximumThrustN, closeTo(19.613300, 1e-6));
      expect(result.realTestTotalMaximumCurrentA, closeTo(13.6, 1e-9));
      expect(result.realTestTotalMaximumPowerW, closeTo(201.28, 1e-9));
      expect(result.realTestThrustToWeight, closeTo(2 / 3, 1e-6));
      expect(result.componentCompatibilityScore, 100);
    });

    test('reports missing catalog combination as incompatible', () {
      final result = AnalysisService().analyze(
        createAircraft(
          motorComponentId: 'unknown-motor',
          propellerComponentId: 'unknown-propeller',
          motorPropellerCombinationId: 'unknown-combination',
        ),
        environment,
      );

      expect(result.usesComponentDatabase, isTrue);
      expect(result.hasRealMotorPropellerData, isFalse);
      expect(result.componentCompatibilityScore, 0);
      expect(result.componentCompatibilityStatus, 'Uyumsuz');
      expect(result.isComponentSelectionCompatible, isFalse);
      expect(
        result.componentCompatibilityMessage,
        contains('katalogda bulunamadı'),
      );
    });

    test('reports propeller diameter mismatch as critical', () {
      final result = AnalysisService().analyze(
        createAircraft(
          motorComponentId: TMotorMn3510Kv360P15x5CfData.motorComponentId,
          propellerComponentId:
              TMotorMn3510Kv360P15x5CfData.propellerComponentId,
          motorPropellerCombinationId:
              TMotorMn3510Kv360P15x5CfData.combinationId,
          propellerDiameterInch: 12.0,
        ),
        environment,
      );

      expect(result.hasRealMotorPropellerData, isTrue);
      expect(result.componentCompatibilityScore, 75);
      expect(result.componentCompatibilityStatus, 'Uyumsuz');
      expect(result.isComponentSelectionCompatible, isFalse);
      expect(result.componentCompatibilityMessage, contains('pervane çapı'));
    });
  });
}
