import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/environment.dart';
import 'package:aerolab/features/analysis/models/aircraft_mass_station.dart';
import 'package:aerolab/features/analysis/services/analysis_service.dart';
import 'package:aerolab/features/analysis/services/risk_service.dart';
import 'package:aerolab/features/analysis/services/score_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const environment = Environment(
    altitudeM: 100.0,
    temperatureC: 20.0,
    pressureHpa: 1001.0,
    humidityPercent: 45.0,
    windSpeedKmh: 5.0,
    windDirection: 'Sakin',
  );

  Aircraft buildFixedWing({
    List<AircraftMassStation>? massStations,
    double maximumOperatingSpeedMs = 25.0,
  }) {
    return Aircraft(
      name: 'Safety Integration Aircraft',
      type: 'Sabit Kanat',
      weightKg: 3.0,
      wingAreaM2: 0.80,
      wingSpanM: 2.0,
      motorCount: 1,
      motorPowerW: 1200.0,
      propellerDiameterInch: 15.0,
      batteryCapacityMah: 10000.0,
      batteryVoltageV: 22.2,
      batteryType: 'LiPo',
      batteryCellCount: 6,
      cellInternalResistanceMilliOhm: 4.0,
      cruiseSpeedMs: 18.0,
      zeroLiftDragCoefficient: 0.035,
      maxLiftCoefficient: 1.40,
      oswaldEfficiencyFactor: 0.80,
      escEfficiency: 0.95,
      motorEfficiency: 0.85,
      continuousMotorPowerW: 1000.0,
      maximumMotorPowerW: 1400.0,
      massStations: massStations ?? const [],
      meanAerodynamicChordM: 0.40,
      macLeadingEdgeFromDatumM: 0.40,
      neutralPointPercentMac: 40.0,
      minimumCgPercentMac: 20.0,
      maximumCgPercentMac: 35.0,
      maximumOperatingSpeedMs: maximumOperatingSpeedMs,
      positiveLimitLoadFactor: 3.8,
      negativeLimitLoadFactor: -1.5,
    );
  }

  group('Safety integration', () {
    test('CG limit violation lowers overall result and status', () {
      final result = AnalysisService().analyze(
        buildFixedWing(
          massStations: const [
            AircraftMassStation(
              name: 'Motor',
              massKg: 0.5,
              armFromDatumM: 0.25,
            ),
            AircraftMassStation(
              name: 'Batarya',
              massKg: 0.8,
              armFromDatumM: 0.46,
            ),
            AircraftMassStation(
              name: 'Gövde',
              massKg: 1.4,
              armFromDatumM: 0.48,
            ),
            AircraftMassStation(name: 'Yük', massKg: 0.3, armFromDatumM: 0.52),
          ],
        ),
        environment,
      );

      expect(result.stability.isApplicable, isTrue);
      expect(result.stability.isCenterOfGravityWithinLimits, isFalse);
      expect(result.overallScore, lessThanOrEqualTo(55));
      expect(result.riskScore, lessThan(60));
      expect(result.status, 'Riskli');
    });

    test('flight envelope violation lowers overall result and status', () {
      final result = AnalysisService().analyze(
        buildFixedWing(maximumOperatingSpeedMs: 16.0),
        environment,
      );

      expect(result.flightEnvelope.isApplicable, isTrue);
      expect(result.flightEnvelope.isCruiseInsideEnvelope, isFalse);
      expect(result.overallScore, lessThanOrEqualTo(55));
      expect(result.riskScore, lessThan(60));
      expect(result.status, 'Riskli');
    });

    test('legacy-safe defaults preserve risk score', () {
      final score = RiskService().calculateRiskScore(
        windSpeedKmh: 0.0,
        thrustToWeight: 1.5,
        evaluateFixedWingAerodynamics: true,
        wingLoading: 40.0,
        flightSpeedMs: 18.0,
        stallSpeedMs: 7.0,
      );

      expect(score, 100);
    });

    test('overall score is capped by critical subsystem safety', () {
      final score = ScoreService().overallScore(
        aerodynamicScore: 100,
        propulsionScore: 100,
        energyScore: 100,
        batteryScore: 100,
        isBatterySystemSafe: false,
      );

      expect(score, 45);
    });
  });
}
