import 'package:flutter_test/flutter_test.dart';
import 'package:aerolab/features/analysis/services/glide_performance_service.dart';

void main() {
  const service = GlidePerformanceService();

  group('GlidePerformanceService', () {
    test('calculates glide performance with valid fixed-wing inputs', () {
      final result = service.calculate(
        massKg: 5.0,
        airDensityKgM3: 1.225,
        wingAreaM2: 0.8,
        aspectRatio: 8.0,
        zeroLiftDragCoefficient: 0.03,
        oswaldEfficiencyFactor: 0.8,
      );

      expect(result.isApplicable, isTrue);
      expect(result.bestGlideRatio, greaterThan(0.0));
      expect(result.bestGlideSpeedMs, greaterThan(0.0));
      expect(
        result.bestGlideSpeedKmh,
        closeTo(result.bestGlideSpeedMs * 3.6, 1e-9),
      );
      expect(result.sinkRateMs, greaterThan(0.0));
      expect(result.glideAngleDeg, greaterThan(0.0));
      expect(result.glideDistanceFrom1000M, greaterThan(1000.0));
      expect(result.glideTimeFrom1000MMinutes, greaterThan(0.0));
      expect(result.canGlide, isTrue);
    });

    test('glide distance from 1000 m matches glide ratio', () {
      final result = service.calculate(
        massKg: 4.0,
        airDensityKgM3: 1.1,
        wingAreaM2: 0.7,
        aspectRatio: 9.0,
        zeroLiftDragCoefficient: 0.025,
        oswaldEfficiencyFactor: 0.82,
      );

      expect(result.isApplicable, isTrue);
      expect(
        result.glideDistanceFrom1000M,
        closeTo(result.bestGlideRatio * 1000.0, 1e-6),
      );
    });

    test('better aerodynamic efficiency improves glide ratio', () {
      final baseline = service.calculate(
        massKg: 5.0,
        airDensityKgM3: 1.225,
        wingAreaM2: 0.8,
        aspectRatio: 6.0,
        zeroLiftDragCoefficient: 0.04,
        oswaldEfficiencyFactor: 0.7,
      );

      final improved = service.calculate(
        massKg: 5.0,
        airDensityKgM3: 1.225,
        wingAreaM2: 0.8,
        aspectRatio: 10.0,
        zeroLiftDragCoefficient: 0.025,
        oswaldEfficiencyFactor: 0.85,
      );

      expect(baseline.isApplicable, isTrue);
      expect(improved.isApplicable, isTrue);
      expect(improved.bestGlideRatio, greaterThan(baseline.bestGlideRatio));
      expect(
        improved.glideDistanceFrom1000M,
        greaterThan(baseline.glideDistanceFrom1000M),
      );
    });

    test('returns not applicable for invalid physical inputs', () {
      final result = service.calculate(
        massKg: 5.0,
        airDensityKgM3: 1.225,
        wingAreaM2: 0.0,
        aspectRatio: 8.0,
        zeroLiftDragCoefficient: 0.03,
        oswaldEfficiencyFactor: 0.8,
      );

      expect(result.isApplicable, isFalse);
      expect(result.bestGlideRatio, 0.0);
      expect(result.bestGlideSpeedMs, 0.0);
      expect(result.sinkRateMs, 0.0);
      expect(result.status, 'Uygulanamaz');
    });

    test('rejects oswald efficiency above physical limit', () {
      final result = service.calculate(
        massKg: 5.0,
        airDensityKgM3: 1.225,
        wingAreaM2: 0.8,
        aspectRatio: 8.0,
        zeroLiftDragCoefficient: 0.03,
        oswaldEfficiencyFactor: 1.2,
      );

      expect(result.isApplicable, isFalse);
      expect(result.canGlide, isFalse);
    });
  });
}
