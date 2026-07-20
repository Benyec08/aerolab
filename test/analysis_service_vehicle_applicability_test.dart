import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/environment.dart';
import 'package:aerolab/features/analysis/services/analysis_service.dart';
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

  Aircraft buildAircraft({
    required String type,
    double wingAreaM2 = 0.60,
    double wingSpanM = 2.0,
    int motorCount = 1,
    double motorPowerW = 500.0,
    double propellerDiameterInch = 12.0,
  }) {
    return Aircraft(
      name: '$type Applicability Test',
      type: type,
      weightKg: 2.4,
      wingAreaM2: wingAreaM2,
      wingSpanM: wingSpanM,
      motorCount: motorCount,
      motorPowerW: motorPowerW,
      propellerDiameterInch: propellerDiameterInch,
      batteryCapacityMah: 8000.0,
      batteryVoltageV: 14.8,
      batteryType: 'LiPo',
      batteryCellCount: 4,
      cruiseSpeedMs: 15.0,
      zeroLiftDragCoefficient: 0.03,
      maxLiftCoefficient: 1.40,
      oswaldEfficiencyFactor: 0.80,
      escEfficiency: 0.95,
      motorEfficiency: 0.85,
      continuousMotorPowerW: 450.0,
      maximumMotorPowerW: 550.0,
    );
  }

  void expectFiniteCommonResults(dynamic result) {
    expect(result.estimatedThrustN.isFinite, isTrue);
    expect(result.thrustToWeight.isFinite, isTrue);
    expect(result.powerToWeight.isFinite, isTrue);
    expect(result.estimatedFlightTime.isFinite, isTrue);
    expect(result.averageMissionPowerW.isFinite, isTrue);
    expect(result.peakMissionPowerW.isFinite, isTrue);
    expect(result.nominalBatteryEnergyWh.isFinite, isTrue);
    expect(result.usableBatteryEnergyWh.isFinite, isTrue);
    expect(result.overallScore, inInclusiveRange(0, 100));
  }

  group('AnalysisService vehicle applicability', () {
    final service = AnalysisService();

    test('Drone disables fixed-wing-only analyses', () {
      final result = service.analyze(
        buildAircraft(
          type: 'Drone',
          wingAreaM2: 0.0,
          wingSpanM: 0.0,
          motorCount: 4,
          motorPowerW: 1200.0,
          propellerDiameterInch: 10.0,
        ),
        environment,
      );

      expect(result.aircraftType, 'Drone');
      expect(result.hasFixedWingAerodynamics, isFalse);

      expect(result.liftN, 0.0);
      expect(result.dragN, 0.0);
      expect(result.aspectRatio, 0.0);
      expect(result.wingLoading, 0.0);
      expect(result.stallSpeed, 0.0);
      expect(result.dynamicPressurePa, 0.0);
      expect(result.requiredLiftCoefficient, 0.0);
      expect(result.dragCoefficient, 0.0);
      expect(result.inducedDragFactor, 0.0);
      expect(result.liftToDragRatio, 0.0);
      expect(result.aerodynamicScore, isNull);
      expect(result.wingLoadingStatus, 'Uygulanamaz');

      expect(result.climbPerformance.isApplicable, isFalse);
      expect(result.enduranceRange.isApplicable, isFalse);
      expect(result.glidePerformance.isApplicable, isFalse);
      expect(result.stability.isApplicable, isFalse);
      expect(result.flightEnvelope.isApplicable, isFalse);

      expect(result.missionPowerModelName, contains('Multikopter'));
      expectFiniteCommonResults(result);
    });

    test('Fixed wing enables aerodynamic and performance analyses', () {
      final result = service.analyze(
        buildAircraft(type: 'Sabit Kanat'),
        environment,
      );

      expect(result.aircraftType, 'Sabit Kanat');
      expect(result.hasFixedWingAerodynamics, isTrue);

      expect(result.liftN, greaterThan(0.0));
      expect(result.dragN, greaterThan(0.0));
      expect(result.aspectRatio, greaterThan(0.0));
      expect(result.wingLoading, greaterThan(0.0));
      expect(result.stallSpeed, greaterThan(0.0));
      expect(result.dynamicPressurePa, greaterThan(0.0));
      expect(result.requiredLiftCoefficient, greaterThan(0.0));
      expect(result.dragCoefficient, greaterThan(0.0));
      expect(result.inducedDragFactor, greaterThan(0.0));
      expect(result.liftToDragRatio, greaterThan(0.0));
      expect(result.aerodynamicScore, isNotNull);

      expect(result.climbPerformance.isApplicable, isTrue);
      expect(result.enduranceRange.isApplicable, isTrue);
      expect(result.glidePerformance.isApplicable, isTrue);

      // Stabilite analizi kütle istasyonları gerektirir.
      // Uçuş zarfı girdileri Aircraft varsayılanlarından sağlanır.
      expect(result.stability.isApplicable, isFalse);
      expect(result.flightEnvelope.isApplicable, isTrue);
      expect(result.flightEnvelope.isCruiseInsideEnvelope, isTrue);

      expect(result.missionPowerModelName, contains('Sabit Kanat'));
      expectFiniteCommonResults(result);
    });

    test('VTOL with wing geometry enables fixed-wing analyses', () {
      final result = service.analyze(
        buildAircraft(
          type: 'VTOL',
          wingAreaM2: 0.60,
          wingSpanM: 2.0,
          motorCount: 4,
          motorPowerW: 1600.0,
          propellerDiameterInch: 12.0,
        ),
        environment,
      );

      expect(result.aircraftType, 'VTOL');
      expect(result.hasFixedWingAerodynamics, isTrue);

      expect(result.liftN, greaterThan(0.0));
      expect(result.dragN, greaterThan(0.0));
      expect(result.aspectRatio, greaterThan(0.0));
      expect(result.wingLoading, greaterThan(0.0));
      expect(result.stallSpeed, greaterThan(0.0));
      expect(result.aerodynamicScore, isNotNull);

      expect(result.climbPerformance.isApplicable, isTrue);
      expect(result.enduranceRange.isApplicable, isTrue);
      expect(result.glidePerformance.isApplicable, isTrue);

      expect(result.missionPowerModelName, contains('VTOL'));
      expectFiniteCommonResults(result);
    });

    test('VTOL without wing geometry safely disables fixed-wing analyses', () {
      final result = service.analyze(
        buildAircraft(
          type: 'VTOL',
          wingAreaM2: 0.0,
          wingSpanM: 0.0,
          motorCount: 4,
          motorPowerW: 1600.0,
          propellerDiameterInch: 12.0,
        ),
        environment,
      );

      expect(result.aircraftType, 'VTOL');
      expect(result.hasFixedWingAerodynamics, isFalse);

      expect(result.liftN, 0.0);
      expect(result.dragN, 0.0);
      expect(result.aspectRatio, 0.0);
      expect(result.wingLoading, 0.0);
      expect(result.stallSpeed, 0.0);
      expect(result.dynamicPressurePa, 0.0);
      expect(result.aerodynamicScore, isNull);
      expect(result.wingLoadingStatus, 'Uygulanamaz');

      expect(result.climbPerformance.isApplicable, isFalse);
      expect(result.enduranceRange.isApplicable, isFalse);
      expect(result.glidePerformance.isApplicable, isFalse);
      expect(result.stability.isApplicable, isFalse);
      expect(result.flightEnvelope.isApplicable, isFalse);

      expect(result.missionPowerModelName, contains('VTOL'));
      expectFiniteCommonResults(result);
    });

    test('partial VTOL wing geometry is treated as not applicable', () {
      final missingSpan = service.analyze(
        buildAircraft(
          type: 'VTOL',
          wingAreaM2: 0.60,
          wingSpanM: 0.0,
          motorCount: 4,
          motorPowerW: 1600.0,
          propellerDiameterInch: 12.0,
        ),
        environment,
      );

      final missingArea = service.analyze(
        buildAircraft(
          type: 'VTOL',
          wingAreaM2: 0.0,
          wingSpanM: 2.0,
          motorCount: 4,
          motorPowerW: 1600.0,
          propellerDiameterInch: 12.0,
        ),
        environment,
      );

      expect(missingSpan.hasFixedWingAerodynamics, isFalse);
      expect(missingArea.hasFixedWingAerodynamics, isFalse);

      expect(missingSpan.aerodynamicScore, isNull);
      expect(missingArea.aerodynamicScore, isNull);

      expect(missingSpan.glidePerformance.isApplicable, isFalse);
      expect(missingArea.glidePerformance.isApplicable, isFalse);

      expectFiniteCommonResults(missingSpan);
      expectFiniteCommonResults(missingArea);
    });

    test('unsupported aircraft type is rejected', () {
      expect(
        () => service.analyze(buildAircraft(type: 'Helikopter'), environment),
        throwsArgumentError,
      );
    });
  });
}
