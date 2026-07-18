import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/environment.dart';
import 'package:aerolab/features/analysis/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalysisService wind integration', () {
    final aircraft = Aircraft(
      name: 'Sprint 13B Test Aircraft',
      type: 'Sabit Kanat',
      weightKg: 5.0,
      wingAreaM2: 1.2,
      wingSpanM: 2.4,
      motorCount: 1,
      motorPowerW: 1800.0,
      propellerDiameterInch: 16.0,
      batteryCapacityMah: 10000.0,
      batteryVoltageV: 22.2,
      batteryType: 'LiPo',
      batteryCellCount: 6,
      cruiseSpeedMs: 20.0,
      zeroLiftDragCoefficient: 0.032,
      maxLiftCoefficient: 1.5,
      oswaldEfficiencyFactor: 0.82,
      escEfficiency: 0.95,
      motorEfficiency: 0.88,
      continuousMotorPowerW: 1600.0,
      maximumMotorPowerW: 2200.0,
    );

    const calmEnvironment = Environment(
      altitudeM: 500.0,
      temperatureC: 15.0,
      pressureHpa: 954.6,
      humidityPercent: 40.0,
      windSpeedKmh: 0.0,
      windDirection: 'Sakin',
    );

    test('copies wind-system results into AnalysisResult', () {
      const environment = Environment(
        altitudeM: 500.0,
        temperatureC: 15.0,
        pressureHpa: 954.6,
        humidityPercent: 40.0,
        windSpeedKmh: 36.0,
        windDirection: 'Karşıdan',
      );

      final result = AnalysisService().analyze(aircraft, environment);

      expect(result.windSpeedKmh, closeTo(36.0, 1e-9));
      expect(result.windSpeedMs, closeTo(10.0, 1e-9));
      expect(result.windDirection, 'Karşıdan');
      expect(result.headwindComponentMs, closeTo(10.0, 1e-9));
      expect(result.tailwindComponentMs, 0.0);
      expect(result.crosswindComponentMs, 0.0);
      expect(result.commandedAirspeedMs, closeTo(20.0, 1e-9));
      expect(result.effectiveAirspeedMs, closeTo(30.0, 1e-9));
      expect(result.estimatedGroundSpeedMs, closeTo(10.0, 1e-9));
      expect(result.windIntensityStatus, isNotEmpty);
      expect(result.windSafetyStatus, isNotEmpty);
      expect(result.isWindWithinSupportedLimits, isTrue);
    });

    test('headwind changes fixed-wing aerodynamic calculations', () {
      const headwindEnvironment = Environment(
        altitudeM: 500.0,
        temperatureC: 15.0,
        pressureHpa: 954.6,
        humidityPercent: 40.0,
        windSpeedKmh: 36.0,
        windDirection: 'Karşıdan',
      );

      final service = AnalysisService();
      final calmResult = service.analyze(aircraft, calmEnvironment);
      final headwindResult = service.analyze(aircraft, headwindEnvironment);

      expect(
        headwindResult.effectiveAirspeedMs,
        greaterThan(calmResult.effectiveAirspeedMs),
      );
      expect(
        headwindResult.dynamicPressurePa,
        greaterThan(calmResult.dynamicPressurePa),
      );
      expect(headwindResult.dragN, greaterThan(calmResult.dragN));
      expect(
        headwindResult.estimatedGroundSpeedMs,
        lessThan(calmResult.estimatedGroundSpeedMs),
      );
    });

    test('tailwind reduces effective airspeed and increases ground speed', () {
      const tailwindEnvironment = Environment(
        altitudeM: 500.0,
        temperatureC: 15.0,
        pressureHpa: 954.6,
        humidityPercent: 40.0,
        windSpeedKmh: 18.0,
        windDirection: 'Arkadan',
      );

      final service = AnalysisService();
      final calmResult = service.analyze(aircraft, calmEnvironment);
      final tailwindResult = service.analyze(aircraft, tailwindEnvironment);

      expect(tailwindResult.tailwindComponentMs, closeTo(5.0, 1e-9));
      expect(
        tailwindResult.effectiveAirspeedMs,
        lessThan(calmResult.effectiveAirspeedMs),
      );
      expect(
        tailwindResult.estimatedGroundSpeedMs,
        greaterThan(calmResult.estimatedGroundSpeedMs),
      );
      expect(
        tailwindResult.dynamicPressurePa,
        lessThan(calmResult.dynamicPressurePa),
      );
    });

    test('crosswind is reported without changing longitudinal airspeed', () {
      const crosswindEnvironment = Environment(
        altitudeM: 500.0,
        temperatureC: 15.0,
        pressureHpa: 954.6,
        humidityPercent: 40.0,
        windSpeedKmh: 18.0,
        windDirection: 'Soldan',
      );

      final result = AnalysisService().analyze(aircraft, crosswindEnvironment);

      expect(result.crosswindComponentMs, closeTo(5.0, 1e-9));
      expect(result.crosswindDirection, 'Soldan');
      expect(result.headwindComponentMs, 0.0);
      expect(result.tailwindComponentMs, 0.0);
      expect(result.effectiveAirspeedMs, closeTo(20.0, 1e-9));
      expect(result.estimatedGroundSpeedMs, closeTo(20.0, 1e-9));
    });
  });
}
