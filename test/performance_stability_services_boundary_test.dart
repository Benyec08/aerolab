import 'package:aerolab/features/analysis/services/aerodynamic_performance_service.dart';
import 'package:aerolab/features/analysis/services/climb_performance_service.dart';
import 'package:aerolab/features/analysis/services/endurance_range_service.dart';
import 'package:aerolab/features/analysis/services/flight_envelope_service.dart';
import 'package:aerolab/features/analysis/services/glide_performance_service.dart';
import 'package:aerolab/features/analysis/services/stability_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AerodynamicPerformanceService boundary tests', () {
    final service = AerodynamicPerformanceService();

    test('calculates finite and physically consistent cruise performance', () {
      final result = service.calculateCruise(
        weightKg: 2.4,
        airDensityKgM3: 1.225,
        cruiseSpeedMs: 15.0,
        wingAreaM2: 0.60,
        aspectRatio: 6.6666666667,
        zeroLiftDragCoefficient: 0.03,
        maxLiftCoefficient: 1.40,
        oswaldEfficiencyFactor: 0.80,
      );

      expect(result.dynamicPressurePa, closeTo(137.8125, 1e-6));
      expect(result.requiredLiftCoefficient.isFinite, isTrue);
      expect(result.dragCoefficient.isFinite, isTrue);
      expect(result.inducedDragFactor.isFinite, isTrue);
      expect(result.liftToDragRatio.isFinite, isTrue);
      expect(result.liftN.isFinite, isTrue);
      expect(result.dragN.isFinite, isTrue);
      expect(result.stallMarginRatio.isFinite, isTrue);

      expect(result.requiredLiftCoefficient, greaterThan(0.0));
      expect(result.dragCoefficient, greaterThan(0.0));
      expect(result.liftToDragRatio, greaterThan(0.0));
      expect(result.dragN, greaterThan(0.0));
      expect(result.liftN, closeTo(2.4 * 9.80665, 1e-6));
      expect(result.isBelowMaximumLiftCoefficient, isTrue);
    });

    test('detects cruise condition above maximum lift coefficient', () {
      final result = service.calculateCruise(
        weightKg: 5.0,
        airDensityKgM3: 1.0,
        cruiseSpeedMs: 5.0,
        wingAreaM2: 0.30,
        aspectRatio: 6.0,
        zeroLiftDragCoefficient: 0.04,
        maxLiftCoefficient: 1.20,
        oswaldEfficiencyFactor: 0.75,
      );

      expect(result.requiredLiftCoefficient, greaterThan(1.20));
      expect(result.stallMarginRatio, greaterThan(1.0));
      expect(result.isBelowMaximumLiftCoefficient, isFalse);
    });

    test('rejects non-positive and non-finite inputs', () {
      expect(
        () => service.calculateCruise(
          weightKg: 0.0,
          airDensityKgM3: 1.225,
          cruiseSpeedMs: 15.0,
          wingAreaM2: 0.60,
          aspectRatio: 6.0,
          zeroLiftDragCoefficient: 0.03,
          maxLiftCoefficient: 1.4,
          oswaldEfficiencyFactor: 0.8,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculateCruise(
          weightKg: 2.4,
          airDensityKgM3: 1.225,
          cruiseSpeedMs: double.nan,
          wingAreaM2: 0.60,
          aspectRatio: 6.0,
          zeroLiftDragCoefficient: 0.03,
          maxLiftCoefficient: 1.4,
          oswaldEfficiencyFactor: 0.8,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculateCruise(
          weightKg: 2.4,
          airDensityKgM3: 1.225,
          cruiseSpeedMs: 15.0,
          wingAreaM2: 0.60,
          aspectRatio: 6.0,
          zeroLiftDragCoefficient: 0.03,
          maxLiftCoefficient: 1.4,
          oswaldEfficiencyFactor: 1.01,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ClimbPerformanceService boundary tests', () {
    const service = ClimbPerformanceService();

    test('calculates positive climb from excess power', () {
      final result = service.calculate(
        massKg: 2.4,
        availablePropulsivePowerW: 319.8,
        requiredLevelFlightPowerW: 43.1,
        flightSpeedMs: 15.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.excessPowerW, closeTo(276.7, 1e-9));
      expect(result.rateOfClimbMs.isFinite, isTrue);
      expect(result.rateOfClimbFpm.isFinite, isTrue);
      expect(result.climbAngleDeg.isFinite, isTrue);
      expect(result.timeTo1000MMinutes.isFinite, isTrue);
      expect(result.rateOfClimbMs, greaterThan(0.0));
      expect(result.climbAngleDeg, inInclusiveRange(0.0, 90.0));
      expect(result.timeTo1000MMinutes, greaterThan(0.0));
    });

    test(
      'returns applicable but unable-to-climb result without excess power',
      () {
        final result = service.calculate(
          massKg: 2.4,
          availablePropulsivePowerW: 40.0,
          requiredLevelFlightPowerW: 50.0,
          flightSpeedMs: 15.0,
        );

        expect(result.isApplicable, isTrue);
        expect(result.excessPowerW, -10.0);
        expect(result.rateOfClimbMs, 0.0);
        expect(result.rateOfClimbFpm, 0.0);
        expect(result.climbAngleDeg, 0.0);
        expect(result.timeTo1000MMinutes, 0.0);
        expect(result.status, 'Tırmanamaz');
      },
    );

    test('returns not-applicable for invalid inputs', () {
      final zeroMass = service.calculate(
        massKg: 0.0,
        availablePropulsivePowerW: 300.0,
        requiredLevelFlightPowerW: 50.0,
        flightSpeedMs: 15.0,
      );

      final nanPower = service.calculate(
        massKg: 2.4,
        availablePropulsivePowerW: double.nan,
        requiredLevelFlightPowerW: 50.0,
        flightSpeedMs: 15.0,
      );

      expect(zeroMass.isApplicable, isFalse);
      expect(nanPower.isApplicable, isFalse);
    });
  });

  group('EnduranceRangeService boundary tests', () {
    const service = EnduranceRangeService();

    test('calculates finite endurance and wind-adjusted range', () {
      final result = service.calculate(
        usableEnergyWh: 104.0,
        cruisePowerW: 70.5,
        cruiseSpeedMs: 15.0,
        estimatedGroundSpeedMs: 16.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.enduranceHours, closeTo(104.0 / 70.5, 1e-9));
      expect(result.enduranceMinutes.isFinite, isTrue);
      expect(result.stillAirRangeKm.isFinite, isTrue);
      expect(result.windAdjustedRangeKm.isFinite, isTrue);
      expect(result.enduranceMinutes, greaterThan(0.0));
      expect(result.windAdjustedRangeKm, greaterThan(result.stillAirRangeKm));
    });

    test('allows zero ground speed and produces zero adjusted range', () {
      final result = service.calculate(
        usableEnergyWh: 104.0,
        cruisePowerW: 70.5,
        cruiseSpeedMs: 15.0,
        estimatedGroundSpeedMs: 0.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.windAdjustedRangeKm, 0.0);
      expect(result.stillAirRangeKm, greaterThan(0.0));
    });

    test('returns not-applicable for invalid energy, power or speed', () {
      final zeroEnergy = service.calculate(
        usableEnergyWh: 0.0,
        cruisePowerW: 70.5,
        cruiseSpeedMs: 15.0,
        estimatedGroundSpeedMs: 15.0,
      );

      final negativeGroundSpeed = service.calculate(
        usableEnergyWh: 104.0,
        cruisePowerW: 70.5,
        cruiseSpeedMs: 15.0,
        estimatedGroundSpeedMs: -1.0,
      );

      expect(zeroEnergy.isApplicable, isFalse);
      expect(negativeGroundSpeed.isApplicable, isFalse);
    });
  });

  group('GlidePerformanceService boundary tests', () {
    const service = GlidePerformanceService();

    test('calculates finite positive best-glide values', () {
      final result = service.calculate(
        massKg: 2.4,
        airDensityKgM3: 1.225,
        wingAreaM2: 0.60,
        aspectRatio: 6.6666666667,
        zeroLiftDragCoefficient: 0.03,
        oswaldEfficiencyFactor: 0.80,
      );

      expect(result.isApplicable, isTrue);
      expect(result.bestGlideRatio.isFinite, isTrue);
      expect(result.bestGlideSpeedMs.isFinite, isTrue);
      expect(result.bestGlideSpeedKmh.isFinite, isTrue);
      expect(result.sinkRateMs.isFinite, isTrue);
      expect(result.glideAngleDeg.isFinite, isTrue);
      expect(result.glideDistanceFrom1000M.isFinite, isTrue);
      expect(result.glideTimeFrom1000MMinutes.isFinite, isTrue);

      expect(result.bestGlideRatio, greaterThan(0.0));
      expect(result.bestGlideSpeedMs, greaterThan(0.0));
      expect(result.sinkRateMs, greaterThan(0.0));
      expect(result.glideAngleDeg, inInclusiveRange(0.0, 90.0));
      expect(
        result.glideDistanceFrom1000M,
        closeTo(result.bestGlideRatio * 1000.0, 1e-6),
      );
    });

    test('returns not-applicable for invalid aerodynamic inputs', () {
      final zeroArea = service.calculate(
        massKg: 2.4,
        airDensityKgM3: 1.225,
        wingAreaM2: 0.0,
        aspectRatio: 6.0,
        zeroLiftDragCoefficient: 0.03,
        oswaldEfficiencyFactor: 0.8,
      );

      final invalidOswald = service.calculate(
        massKg: 2.4,
        airDensityKgM3: 1.225,
        wingAreaM2: 0.6,
        aspectRatio: 6.0,
        zeroLiftDragCoefficient: 0.03,
        oswaldEfficiencyFactor: 1.1,
      );

      expect(zeroArea.isApplicable, isFalse);
      expect(invalidOswald.isApplicable, isFalse);
    });
  });

  group('FlightEnvelopeService boundary tests', () {
    const service = FlightEnvelopeService();

    test('calculates an inside-envelope operating point', () {
      final result = service.calculate(
        airDensityKgM3: 1.225,
        stallSpeedMs: 6.8,
        cruiseSpeedMs: 15.0,
        maximumOperatingSpeedMs: 25.0,
        positiveLimitLoadFactor: 3.8,
        negativeLimitLoadFactor: -1.5,
      );

      expect(result.isApplicable, isTrue);
      expect(result.minimumOperatingSpeedMs, closeTo(8.16, 1e-9));
      expect(result.maneuveringSpeedMs.isFinite, isTrue);
      expect(result.maximumDynamicPressurePa.isFinite, isTrue);
      expect(result.maximumDynamicPressurePa, greaterThan(0.0));
      expect(result.isCruiseInsideEnvelope, isTrue);
    });

    test('detects insufficient stall margin and maximum-speed exceedance', () {
      final belowMinimum = service.calculate(
        airDensityKgM3: 1.225,
        stallSpeedMs: 10.0,
        cruiseSpeedMs: 11.0,
        maximumOperatingSpeedMs: 25.0,
        positiveLimitLoadFactor: 3.8,
        negativeLimitLoadFactor: -1.5,
      );

      final aboveMaximum = service.calculate(
        airDensityKgM3: 1.225,
        stallSpeedMs: 6.8,
        cruiseSpeedMs: 26.0,
        maximumOperatingSpeedMs: 25.0,
        positiveLimitLoadFactor: 3.8,
        negativeLimitLoadFactor: -1.5,
      );

      expect(belowMinimum.isCruiseInsideEnvelope, isFalse);
      expect(belowMinimum.status, 'Stall Marjı Yetersiz');
      expect(aboveMaximum.isCruiseInsideEnvelope, isFalse);
      expect(aboveMaximum.status, 'Maksimum Hız Aşımı');
    });

    test('returns not-applicable for inconsistent envelope inputs', () {
      final invalidMaximumSpeed = service.calculate(
        airDensityKgM3: 1.225,
        stallSpeedMs: 10.0,
        cruiseSpeedMs: 15.0,
        maximumOperatingSpeedMs: 10.0,
        positiveLimitLoadFactor: 3.8,
        negativeLimitLoadFactor: -1.5,
      );

      final invalidLoadFactors = service.calculate(
        airDensityKgM3: 1.225,
        stallSpeedMs: 6.8,
        cruiseSpeedMs: 15.0,
        maximumOperatingSpeedMs: 25.0,
        positiveLimitLoadFactor: 1.0,
        negativeLimitLoadFactor: 0.0,
      );

      expect(invalidMaximumSpeed.isApplicable, isFalse);
      expect(invalidLoadFactors.isApplicable, isFalse);
    });
  });

  group('StabilityService boundary tests', () {
    const service = StabilityService();

    test('calculates finite CG and positive static margin', () {
      final result = service.calculate(
        massStations: const [
          MassStation(name: 'Motor', massKg: 0.50, armFromDatumM: 0.10),
          MassStation(name: 'Battery', massKg: 0.80, armFromDatumM: 0.20),
          MassStation(name: 'Airframe', massKg: 1.10, armFromDatumM: 0.30),
        ],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.15,
        neutralPointPercentMac: 40.0,
        minimumCgPercentMac: 15.0,
        maximumCgPercentMac: 35.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.centerOfGravityFromLeadingEdgeM.isFinite, isTrue);
      expect(result.centerOfGravityPercentMac.isFinite, isTrue);
      expect(result.neutralPointFromLeadingEdgeM.isFinite, isTrue);
      expect(result.staticMarginPercent.isFinite, isTrue);
      expect(result.isStaticallyStable, isTrue);
      expect(result.staticMarginPercent, greaterThan(0.0));
    });

    test('detects an unstable CG behind the neutral point', () {
      final result = service.calculate(
        massStations: const [
          MassStation(name: 'Rear Mass', massKg: 2.0, armFromDatumM: 0.40),
        ],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.10,
        neutralPointPercentMac: 40.0,
        minimumCgPercentMac: 0.0,
        maximumCgPercentMac: 100.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.centerOfGravityPercentMac, closeTo(75.0, 1e-9));
      expect(result.staticMarginPercent, closeTo(-35.0, 1e-9));
      expect(result.isStaticallyStable, isFalse);
    });

    test('returns not-applicable for missing or invalid mass stations', () {
      final empty = service.calculate(
        massStations: const [],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.15,
        neutralPointPercentMac: 40.0,
        minimumCgPercentMac: 15.0,
        maximumCgPercentMac: 35.0,
      );

      final invalidMass = service.calculate(
        massStations: const [
          MassStation(name: 'Battery', massKg: 0.0, armFromDatumM: 0.20),
        ],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.15,
        neutralPointPercentMac: 40.0,
        minimumCgPercentMac: 15.0,
        maximumCgPercentMac: 35.0,
      );

      expect(empty.isApplicable, isFalse);
      expect(invalidMass.isApplicable, isFalse);
    });

    test('returns not-applicable for invalid CG and neutral-point limits', () {
      final invalidLimits = service.calculate(
        massStations: const [
          MassStation(name: 'Battery', massKg: 1.0, armFromDatumM: 0.20),
        ],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.15,
        neutralPointPercentMac: 101.0,
        minimumCgPercentMac: 35.0,
        maximumCgPercentMac: 15.0,
      );

      expect(invalidLimits.isApplicable, isFalse);
    });
  });
}
