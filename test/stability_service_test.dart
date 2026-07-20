import 'package:flutter_test/flutter_test.dart';
import 'package:aerolab/features/analysis/services/stability_service.dart';

void main() {
  const service = StabilityService();

  group('StabilityService', () {
    test('calculates center of gravity and static margin correctly', () {
      final result = service.calculate(
        massStations: const [
          MassStation(name: 'Motor', massKg: 1.0, armFromDatumM: 0.20),
          MassStation(name: 'Battery', massKg: 2.0, armFromDatumM: 0.40),
          MassStation(name: 'Airframe', massKg: 2.0, armFromDatumM: 0.50),
        ],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.30,
        neutralPointPercentMac: 40.0,
        minimumCgPercentMac: 20.0,
        maximumCgPercentMac: 35.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.centerOfGravityFromLeadingEdgeM, closeTo(0.10, 1e-9));
      expect(result.centerOfGravityPercentMac, closeTo(25.0, 1e-9));
      expect(result.neutralPointFromLeadingEdgeM, closeTo(0.16, 1e-9));
      expect(result.neutralPointPercentMac, closeTo(40.0, 1e-9));
      expect(result.staticMarginPercent, closeTo(15.0, 1e-9));
      expect(result.isCenterOfGravityWithinLimits, isTrue);
      expect(result.isStaticallyStable, isTrue);
      expect(result.hasPositiveStaticMargin, isTrue);
      expect(result.status, 'Kararlı');
    });

    test('detects center of gravity outside limits', () {
      final result = service.calculate(
        massStations: const [
          MassStation(name: 'Motor', massKg: 1.0, armFromDatumM: 0.20),
          MassStation(name: 'Battery', massKg: 3.0, armFromDatumM: 0.55),
        ],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.30,
        neutralPointPercentMac: 45.0,
        minimumCgPercentMac: 20.0,
        maximumCgPercentMac: 35.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.isCenterOfGravityWithinLimits, isFalse);
      expect(result.status, 'CG Limit Dışı');
      expect(result.message, contains('güvenli CG limitlerinin dışındadır'));
    });

    test('detects static instability with negative static margin', () {
      final result = service.calculate(
        massStations: const [
          MassStation(name: 'Payload', massKg: 4.0, armFromDatumM: 0.52),
        ],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.30,
        neutralPointPercentMac: 40.0,
        minimumCgPercentMac: 20.0,
        maximumCgPercentMac: 60.0,
      );

      expect(result.isApplicable, isTrue);
      expect(result.centerOfGravityPercentMac, closeTo(55.0, 1e-9));
      expect(result.staticMarginPercent, closeTo(-15.0, 1e-9));
      expect(result.isStaticallyStable, isFalse);
      expect(result.hasPositiveStaticMargin, isFalse);
      expect(result.status, 'Kararsız');
    });

    test('returns not applicable for empty mass stations', () {
      final result = service.calculate(
        massStations: const [],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.30,
        neutralPointPercentMac: 40.0,
        minimumCgPercentMac: 20.0,
        maximumCgPercentMac: 35.0,
      );

      expect(result.isApplicable, isFalse);
      expect(result.centerOfGravityPercentMac, 0.0);
      expect(result.staticMarginPercent, 0.0);
      expect(result.status, 'Uygulanamaz');
    });

    test('returns not applicable for invalid station mass', () {
      final result = service.calculate(
        massStations: const [
          MassStation(name: 'Battery', massKg: 0.0, armFromDatumM: 0.40),
        ],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.30,
        neutralPointPercentMac: 40.0,
        minimumCgPercentMac: 20.0,
        maximumCgPercentMac: 35.0,
      );

      expect(result.isApplicable, isFalse);
      expect(result.isStaticallyStable, isFalse);
    });
  });
}
