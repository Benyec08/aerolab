import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/environment.dart';
import 'package:aerolab/features/analysis/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalysisService atmosphere integration', () {
    final aircraft = Aircraft(
      name: 'Sprint 13A Test Aircraft',
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

    test('copies atmosphere results into AnalysisResult', () {
      const environment = Environment(
        altitudeM: 1200.0,
        temperatureC: 25.0,
        pressureHpa: 880.0,
        humidityPercent: 60.0,
        windSpeedKmh: 15.0,
        windDirection: 'Karşıdan',
      );

      final result = AnalysisService().analyze(aircraft, environment);

      expect(result.geometricAltitudeM, environment.altitudeM);
      expect(result.environmentTemperatureC, environment.temperatureC);
      expect(result.environmentPressureHpa, environment.pressureHpa);
      expect(result.relativeHumidityPercent, environment.humidityPercent);
      expect(result.humidAirDensityKgM3, greaterThan(0));
      expect(result.isaDensityKgM3, greaterThan(0));
      expect(result.densityAltitudeM.isFinite, isTrue);
      expect(result.atmosphereStatus, isNotEmpty);
      expect(result.isAtmosphereWithinSupportedLimits, isTrue);
    });

    test('uses humid-air density in engineering calculations', () {
      const dryEnvironment = Environment(
        altitudeM: 0.0,
        temperatureC: 30.0,
        pressureHpa: 1013.25,
        humidityPercent: 0.0,
        windSpeedKmh: 0.0,
        windDirection: 'Sakin',
      );

      const humidEnvironment = Environment(
        altitudeM: 0.0,
        temperatureC: 30.0,
        pressureHpa: 1013.25,
        humidityPercent: 100.0,
        windSpeedKmh: 0.0,
        windDirection: 'Sakin',
      );

      final service = AnalysisService();
      final dryResult = service.analyze(aircraft, dryEnvironment);
      final humidResult = service.analyze(aircraft, humidEnvironment);

      expect(
        humidResult.humidAirDensityKgM3,
        lessThan(dryResult.humidAirDensityKgM3),
      );
      expect(
        humidResult.dynamicPressurePa,
        lessThan(dryResult.dynamicPressurePa),
      );
      expect(humidResult.stallSpeed, greaterThan(dryResult.stallSpeed));
    });
  });
}
