import 'dart:math' as math;

import 'package:aerolab/features/analysis/services/flight_envelope_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FlightEnvelopeService();

  group('FlightEnvelopeService', () {
    test('calculates a valid flight envelope', () {
      final result = service.calculate(
        airDensityKgM3: 1.225,
        stallSpeedMs: 10.0,
        cruiseSpeedMs: 14.0,
        maximumOperatingSpeedMs: 25.0,
        positiveLimitLoadFactor: 3.8,
        negativeLimitLoadFactor: -1.5,
      );

      expect(result.isApplicable, isTrue);
      expect(result.minimumOperatingSpeedMs, closeTo(12.0, 1e-9));
      expect(result.maneuveringSpeedMs, closeTo(10.0 * math.sqrt(3.8), 1e-9));
      expect(result.maximumDynamicPressurePa, closeTo(382.8125, 1e-9));
      expect(result.isCruiseInsideEnvelope, isTrue);
      expect(result.status, 'Zarf İçinde');
      expect(result.hasValidSpeedRange, isTrue);
    });

    test('detects insufficient stall margin', () {
      final result = service.calculate(
        airDensityKgM3: 1.225,
        stallSpeedMs: 10.0,
        cruiseSpeedMs: 11.0,
        maximumOperatingSpeedMs: 25.0,
        positiveLimitLoadFactor: 3.8,
        negativeLimitLoadFactor: -1.5,
      );

      expect(result.isApplicable, isTrue);
      expect(result.isCruiseInsideEnvelope, isFalse);
      expect(result.status, 'Stall Marjı Yetersiz');
      expect(result.message, contains('minimum işletme hızı'));
    });

    test('detects maximum operating speed exceedance', () {
      final result = service.calculate(
        airDensityKgM3: 1.225,
        stallSpeedMs: 10.0,
        cruiseSpeedMs: 27.0,
        maximumOperatingSpeedMs: 25.0,
        positiveLimitLoadFactor: 3.8,
        negativeLimitLoadFactor: -1.5,
      );

      expect(result.isApplicable, isTrue);
      expect(result.isCruiseInsideEnvelope, isFalse);
      expect(result.status, 'Maksimum Hız Aşımı');
    });

    test('marks cruise above maneuvering speed as maneuver limited', () {
      final result = service.calculate(
        airDensityKgM3: 1.225,
        stallSpeedMs: 10.0,
        cruiseSpeedMs: 20.0,
        maximumOperatingSpeedMs: 30.0,
        positiveLimitLoadFactor: 3.8,
        negativeLimitLoadFactor: -1.5,
      );

      expect(result.isApplicable, isTrue);
      expect(result.isCruiseInsideEnvelope, isTrue);
      expect(result.cruiseSpeedMs, greaterThan(result.maneuveringSpeedMs));
      expect(result.status, 'Zarf İçinde — Manevra Kısıtlı');
    });

    test('returns not applicable for invalid load factor inputs', () {
      final result = service.calculate(
        airDensityKgM3: 1.225,
        stallSpeedMs: 10.0,
        cruiseSpeedMs: 14.0,
        maximumOperatingSpeedMs: 25.0,
        positiveLimitLoadFactor: 1.0,
        negativeLimitLoadFactor: 0.0,
      );

      expect(result.isApplicable, isFalse);
      expect(result.status, 'Uygulanamaz');
      expect(result.maximumDynamicPressurePa, 0.0);
    });
  });
}
