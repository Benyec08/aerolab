import 'package:flutter_test/flutter_test.dart';

import 'package:aerolab/features/analysis/services/propulsion_load_service.dart';
import 'package:aerolab/features/analysis/services/propulsion_power_chain_service.dart';
import 'package:aerolab/features/analysis/services/propulsion_system_service.dart';

void main() {
  group('PropulsionPowerChainService', () {
    final service = PropulsionPowerChainService();

    test('güç zincirini ve kayıpları doğru hesaplar', () {
      final result = service.calculate(
        batteryElectricalPowerW: 1000,
        escEfficiency: 0.95,
        motorEfficiency: 0.88,
        propellerEfficiency: 0.72,
      );

      expect(result.escOutputPowerW, closeTo(950, 0.001));
      expect(result.motorShaftPowerW, closeTo(836, 0.001));
      expect(result.usefulPropulsivePowerW, closeTo(601.92, 0.001));

      expect(result.escPowerLossW, closeTo(50, 0.001));
      expect(result.motorPowerLossW, closeTo(114, 0.001));
      expect(result.propellerPowerLossW, closeTo(234.08, 0.001));
      expect(result.totalPowerLossW, closeTo(398.08, 0.001));

      expect(result.totalPropulsionEfficiency, closeTo(0.60192, 0.000001));
    });

    test('geçersiz verim değerini reddeder', () {
      expect(
        () => service.calculate(
          batteryElectricalPowerW: 1000,
          escEfficiency: 1.10,
          motorEfficiency: 0.88,
          propellerEfficiency: 0.72,
        ),
        throwsArgumentError,
      );
    });
  });

  group('PropulsionLoadService', () {
    final service = PropulsionLoadService();

    test('normal motor yükünü doğru hesaplar', () {
      final result = service.calculate(
        averageMissionPowerW: 400,
        peakMissionPowerW: 700,
        continuousMotorPowerW: 1000,
        maximumMotorPowerW: 1200,
      );

      expect(result.averageContinuousLoadRatio, closeTo(0.40, 0.001));
      expect(result.peakContinuousLoadRatio, closeTo(0.70, 0.001));
      expect(result.peakMaximumLoadRatio, closeTo(0.583333, 0.001));

      expect(result.continuousPowerReserveW, closeTo(600, 0.001));
      expect(result.maximumPowerReserveW, closeTo(500, 0.001));

      expect(result.exceedsContinuousLimit, isFalse);
      expect(result.exceedsMaximumLimit, isFalse);
      expect(result.status, PropulsionLoadStatus.normal);
    });

    test('maksimum motor gücü aşımını tespit eder', () {
      final result = service.calculate(
        averageMissionPowerW: 900,
        peakMissionPowerW: 1300,
        continuousMotorPowerW: 1000,
        maximumMotorPowerW: 1200,
      );

      expect(result.exceedsMaximumLimit, isTrue);
      expect(result.status, PropulsionLoadStatus.maximumLimitExceeded);
    });

    test('maksimum güç sürekli güçten küçükse hata verir', () {
      expect(
        () => service.calculate(
          averageMissionPowerW: 400,
          peakMissionPowerW: 700,
          continuousMotorPowerW: 1200,
          maximumMotorPowerW: 1000,
        ),
        throwsArgumentError,
      );
    });
  });

  group('PropulsionSystemService', () {
    final service = PropulsionSystemService();

    test('Eagle X-11 benzeri güvenli sistemi doğru sınıflandırır', () {
      final result = service.calculate(
        averageMissionPowerW: 124,
        peakMissionPowerW: 193,
        escEfficiency: 0.95,
        motorEfficiency: 0.88,
        propellerEfficiency: 0.72,
        continuousMotorPowerW: 1300,
        maximumMotorPowerW: 1500,
      );

      expect(result.totalPropulsionEfficiency, closeTo(0.60192, 0.000001));

      expect(result.averagePowerChain.escOutputPowerW, closeTo(117.8, 0.001));

      expect(
        result.averagePowerChain.motorShaftPowerW,
        closeTo(103.664, 0.001),
      );

      expect(
        result.averagePowerChain.usefulPropulsivePowerW,
        closeTo(74.63808, 0.001),
      );

      expect(
        result.loadAnalysis.averageContinuousLoadRatio,
        closeTo(124 / 1300, 0.001),
      );

      expect(
        result.loadAnalysis.peakMaximumLoadRatio,
        closeTo(193 / 1500, 0.001),
      );

      expect(result.status, PropulsionSystemStatus.good);
      expect(result.status.isSafe, isTrue);
    });

    test('maksimum güç aşımını güvensiz olarak sınıflandırır', () {
      final result = service.calculate(
        averageMissionPowerW: 950,
        peakMissionPowerW: 1300,
        escEfficiency: 0.95,
        motorEfficiency: 0.88,
        propellerEfficiency: 0.72,
        continuousMotorPowerW: 1000,
        maximumMotorPowerW: 1200,
      );

      expect(result.status, PropulsionSystemStatus.maximumPowerExceeded);
      expect(result.status.isSafe, isFalse);
    });
  });
}
