import 'package:flutter_test/flutter_test.dart';
import 'package:aerolab/features/analysis/services/endurance_range_service.dart';

void main() {
  const service = EnduranceRangeService();

  group('EnduranceRangeService', () {
    test('calculates endurance and still-air range correctly', () {
      final result = service.calculate(
        usableEnergyWh: 200.0,
        cruisePowerW: 100.0,
        cruiseSpeedMs: 20.0,
        estimatedGroundSpeedMs: 20.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.enduranceHours, closeTo(2.0, 1e-9));
      expect(result.enduranceMinutes, closeTo(120.0, 1e-9));
      expect(result.cruiseSpeedKmh, closeTo(72.0, 1e-9));
      expect(result.stillAirRangeKm, closeTo(144.0, 1e-9));
      expect(result.windAdjustedRangeKm, closeTo(144.0, 1e-9));
      expect(result.hasPositiveEndurance, isTrue);
      expect(result.hasPositiveRange, isTrue);
      expect(result.status, 'Yüksek');
    });

    test('tailwind increases wind-adjusted range', () {
      final result = service.calculate(
        usableEnergyWh: 100.0,
        cruisePowerW: 100.0,
        cruiseSpeedMs: 20.0,
        estimatedGroundSpeedMs: 25.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.stillAirRangeKm, closeTo(72.0, 1e-9));
      expect(result.windAdjustedRangeKm, closeTo(90.0, 1e-9));
      expect(result.windAdjustedRangeKm, greaterThan(result.stillAirRangeKm));
      expect(result.message, contains('arka rüzgâr menzili artırmıştır'));
    });

    test('headwind decreases wind-adjusted range', () {
      final result = service.calculate(
        usableEnergyWh: 100.0,
        cruisePowerW: 100.0,
        cruiseSpeedMs: 20.0,
        estimatedGroundSpeedMs: 15.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.stillAirRangeKm, closeTo(72.0, 1e-9));
      expect(result.windAdjustedRangeKm, closeTo(54.0, 1e-9));
      expect(result.windAdjustedRangeKm, lessThan(result.stillAirRangeKm));
      expect(result.message, contains('karşı rüzgâr menzili azaltmıştır'));
    });

    test('allows zero ground speed with zero wind-adjusted range', () {
      final result = service.calculate(
        usableEnergyWh: 50.0,
        cruisePowerW: 100.0,
        cruiseSpeedMs: 20.0,
        estimatedGroundSpeedMs: 0.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.enduranceMinutes, closeTo(30.0, 1e-9));
      expect(result.windAdjustedRangeKm, 0.0);
      expect(result.hasPositiveEndurance, isTrue);
      expect(result.hasPositiveRange, isFalse);
    });

    test('returns not applicable for invalid physical inputs', () {
      final result = service.calculate(
        usableEnergyWh: 0.0,
        cruisePowerW: 100.0,
        cruiseSpeedMs: 20.0,
        estimatedGroundSpeedMs: 20.0,
      );

      expect(result.isApplicable, isFalse);
      expect(result.enduranceHours, 0.0);
      expect(result.stillAirRangeKm, 0.0);
      expect(result.windAdjustedRangeKm, 0.0);
      expect(result.status, 'Uygulanamaz');
    });
  });
}
