import 'package:flutter_test/flutter_test.dart';
import 'package:aerolab/features/analysis/services/climb_performance_service.dart';

void main() {
  const service = ClimbPerformanceService();

  group('ClimbPerformanceService', () {
    test('calculates positive climb performance from excess power', () {
      final result = service.calculate(
        massKg: 5.0,
        availablePropulsivePowerW: 1200.0,
        requiredLevelFlightPowerW: 700.0,
        flightSpeedMs: 20.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.excessPowerW, closeTo(500.0, 1e-9));
      expect(result.rateOfClimbMs, closeTo(10.1972, 1e-3));
      expect(result.rateOfClimbFpm, closeTo(2007.3, 0.5));
      expect(result.climbAngleDeg, greaterThan(0.0));
      expect(result.timeTo1000MMinutes, greaterThan(0.0));
      expect(result.canClimb, isTrue);
      expect(result.hasPositiveExcessPower, isTrue);
      expect(result.status, 'Yüksek Tırmanma');
    });

    test('returns cannot climb when available power is insufficient', () {
      final result = service.calculate(
        massKg: 5.0,
        availablePropulsivePowerW: 500.0,
        requiredLevelFlightPowerW: 700.0,
        flightSpeedMs: 20.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.excessPowerW, closeTo(-200.0, 1e-9));
      expect(result.rateOfClimbMs, 0.0);
      expect(result.rateOfClimbFpm, 0.0);
      expect(result.climbAngleDeg, 0.0);
      expect(result.timeTo1000MMinutes, 0.0);
      expect(result.canClimb, isFalse);
      expect(result.hasPositiveExcessPower, isFalse);
      expect(result.status, 'Tırmanamaz');
    });

    test('returns not applicable for invalid physical inputs', () {
      final result = service.calculate(
        massKg: 0.0,
        availablePropulsivePowerW: 1200.0,
        requiredLevelFlightPowerW: 700.0,
        flightSpeedMs: 20.0,
      );

      expect(result.isApplicable, isFalse);
      expect(result.rateOfClimbMs, 0.0);
      expect(result.excessPowerW, 0.0);
      expect(result.status, 'Uygulanamaz');
    });

    test('limits climb angle calculation to a physical asin domain', () {
      final result = service.calculate(
        massKg: 1.0,
        availablePropulsivePowerW: 5000.0,
        requiredLevelFlightPowerW: 100.0,
        flightSpeedMs: 10.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.climbAngleDeg, closeTo(90.0, 1e-9));
    });
  });
}
