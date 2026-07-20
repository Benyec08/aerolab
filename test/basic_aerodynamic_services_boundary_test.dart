import 'package:aerolab/features/analysis/services/air_density_service.dart';
import 'package:aerolab/features/analysis/services/aspect_ratio_service.dart';
import 'package:aerolab/features/analysis/services/drag_service.dart';
import 'package:aerolab/features/analysis/services/lift_service.dart';
import 'package:aerolab/features/analysis/services/power_to_weight_service.dart';
import 'package:aerolab/features/analysis/services/stall_service.dart';
import 'package:aerolab/features/analysis/services/wing_loading_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AirDensityService boundary tests', () {
    final service = AirDensityService();

    test('calculates standard sea-level density', () {
      final density = service.calculate(
        temperatureC: 15.0,
        pressureHpa: 1013.25,
      );

      expect(density, closeTo(1.225, 0.002));
      expect(density.isFinite, isTrue);
      expect(density, greaterThan(0.0));
    });

    test('calculates finite positive density at maximum altitude', () {
      final density = service.calculateIsaDensity(altitudeM: 20000.0);

      expect(density.isFinite, isTrue);
      expect(density, greaterThan(0.0));
    });

    test('rejects zero or negative pressure', () {
      expect(
        () => service.calculate(temperatureC: 15.0, pressureHpa: 0.0),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(temperatureC: 15.0, pressureHpa: -1.0),
        throwsArgumentError,
      );
    });

    test('rejects absolute zero and non-finite temperature', () {
      expect(
        () => service.calculate(temperatureC: -273.15, pressureHpa: 1013.25),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(temperatureC: double.nan, pressureHpa: 1013.25),
        throwsArgumentError,
      );
    });

    test('rejects unsupported and non-finite altitude', () {
      expect(
        () => service.calculateIsaDensity(altitudeM: -501.0),
        throwsArgumentError,
      );

      expect(
        () => service.calculateIsaDensity(altitudeM: 20001.0),
        throwsArgumentError,
      );

      expect(
        () => service.calculateIsaDensity(altitudeM: double.infinity),
        throwsArgumentError,
      );
    });
  });

  group('LiftService boundary tests', () {
    final service = LiftService();

    test('calculates expected lift for valid inputs', () {
      final lift = service.calculate(
        airDensity: 1.225,
        velocityMs: 15.0,
        wingAreaM2: 0.60,
        liftCoefficient: 1.1,
      );

      expect(lift, closeTo(90.95625, 1e-6));
      expect(lift.isFinite, isTrue);
    });

    test('returns zero lift at zero velocity', () {
      final lift = service.calculate(
        airDensity: 1.225,
        velocityMs: 0.0,
        wingAreaM2: 0.60,
        liftCoefficient: 1.1,
      );

      expect(lift, 0.0);
    });

    test('rejects invalid physical inputs', () {
      expect(
        () => service.calculate(
          airDensity: 0.0,
          velocityMs: 15.0,
          wingAreaM2: 0.60,
          liftCoefficient: 1.1,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          airDensity: 1.225,
          velocityMs: -1.0,
          wingAreaM2: 0.60,
          liftCoefficient: 1.1,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          airDensity: 1.225,
          velocityMs: 15.0,
          wingAreaM2: 0.0,
          liftCoefficient: 1.1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('DragService boundary tests', () {
    final service = DragService();

    test('calculates expected drag for valid inputs', () {
      final drag = service.calculate(
        airDensity: 1.225,
        velocityMs: 15.0,
        wingAreaM2: 0.60,
        dragCoefficient: 0.045,
      );

      expect(drag, closeTo(3.7209375, 1e-7));
      expect(drag.isFinite, isTrue);
    });

    test('returns zero drag at zero velocity', () {
      final drag = service.calculate(
        airDensity: 1.225,
        velocityMs: 0.0,
        wingAreaM2: 0.60,
        dragCoefficient: 0.045,
      );

      expect(drag, 0.0);
    });

    test('rejects invalid physical inputs', () {
      expect(
        () => service.calculate(
          airDensity: -1.0,
          velocityMs: 15.0,
          wingAreaM2: 0.60,
          dragCoefficient: 0.045,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          airDensity: 1.225,
          velocityMs: -1.0,
          wingAreaM2: 0.60,
          dragCoefficient: 0.045,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          airDensity: 1.225,
          velocityMs: 15.0,
          wingAreaM2: 0.60,
          dragCoefficient: -0.01,
        ),
        throwsArgumentError,
      );
    });
  });

  group('StallService boundary tests', () {
    final service = StallService();

    test('calculates finite positive stall speed for valid inputs', () {
      final stallSpeed = service.calculate(
        weightKg: 2.40,
        wingAreaM2: 0.60,
        airDensity: 1.225,
        clMax: 1.40,
      );

      expect(stallSpeed, closeTo(6.764, 0.01));
      expect(stallSpeed.isFinite, isTrue);
      expect(stallSpeed, greaterThan(0.0));
    });

    test('rejects zero and negative physical inputs', () {
      expect(
        () => service.calculate(
          weightKg: 0.0,
          wingAreaM2: 0.60,
          airDensity: 1.225,
          clMax: 1.40,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          weightKg: 2.40,
          wingAreaM2: 0.0,
          airDensity: 1.225,
          clMax: 1.40,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          weightKg: 2.40,
          wingAreaM2: 0.60,
          airDensity: 0.0,
          clMax: 1.40,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          weightKg: 2.40,
          wingAreaM2: 0.60,
          airDensity: 1.225,
          clMax: 0.0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Aircraft ratio service boundary tests', () {
    final aspectRatioService = AspectRatioService();
    final wingLoadingService = WingLoadingService();
    final powerToWeightService = PowerToWeightService();

    test('aspect ratio returns zero for non-positive wing area', () {
      expect(
        aspectRatioService.calculate(wingSpanM: 2.0, wingAreaM2: 0.0),
        0.0,
      );

      expect(
        aspectRatioService.calculate(wingSpanM: 2.0, wingAreaM2: -1.0),
        0.0,
      );
    });

    test('wing loading returns zero for non-positive wing area', () {
      expect(wingLoadingService.calculate(weightKg: 2.4, wingAreaM2: 0.0), 0.0);
    });

    test('power-to-weight returns zero for non-positive weight', () {
      expect(
        powerToWeightService.calculate(motorPowerW: 500.0, weightKg: 0.0),
        0.0,
      );

      expect(
        powerToWeightService.calculate(motorPowerW: 500.0, weightKg: -1.0),
        0.0,
      );
    });

    test('valid ratio calculations remain finite', () {
      final aspectRatio = aspectRatioService.calculate(
        wingSpanM: 2.0,
        wingAreaM2: 0.60,
      );
      final wingLoading = wingLoadingService.calculate(
        weightKg: 2.40,
        wingAreaM2: 0.60,
      );
      final powerToWeight = powerToWeightService.calculate(
        motorPowerW: 500.0,
        weightKg: 2.40,
      );

      expect(aspectRatio, closeTo(6.6667, 0.0001));
      expect(wingLoading, 4.0);
      expect(powerToWeight, closeTo(208.3333, 0.0001));

      expect(aspectRatio.isFinite, isTrue);
      expect(wingLoading.isFinite, isTrue);
      expect(powerToWeight.isFinite, isTrue);
    });
  });
}
