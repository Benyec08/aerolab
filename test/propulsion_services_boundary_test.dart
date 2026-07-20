import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/services/mission_power_service.dart';
import 'package:aerolab/features/analysis/services/motor_efficiency_service.dart';
import 'package:aerolab/features/analysis/services/propulsion_load_service.dart';
import 'package:aerolab/features/analysis/services/propulsion_power_chain_service.dart';
import 'package:aerolab/features/analysis/services/propulsion_system_service.dart';
import 'package:aerolab/features/analysis/services/thrust_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Aircraft buildAircraft({
    String type = 'Sabit Kanat',
    double weightKg = 2.4,
    int motorCount = 1,
    double motorPowerW = 500.0,
    double propellerDiameterInch = 12.0,
  }) {
    return Aircraft(
      name: 'Boundary Test Aircraft',
      type: type,
      weightKg: weightKg,
      wingAreaM2: 0.60,
      wingSpanM: 2.0,
      motorCount: motorCount,
      motorPowerW: motorPowerW,
      propellerDiameterInch: propellerDiameterInch,
      batteryCapacityMah: 8000.0,
      batteryVoltageV: 14.8,
      batteryType: 'LiPo',
      batteryCellCount: 4,
      continuousMotorPowerW: 450.0,
      maximumMotorPowerW: 550.0,
    );
  }

  group('MotorEfficiencyService boundary tests', () {
    final service = MotorEfficiencyService();

    test('calculates finite shaft power', () {
      final shaftPower = service.calculateShaftPowerW(
        electricalPowerW: 500.0,
        efficiency: 0.85,
      );

      expect(shaftPower, 425.0);
      expect(shaftPower.isFinite, isTrue);
    });

    test('rejects invalid power', () {
      expect(
        () => service.calculateShaftPowerW(electricalPowerW: 0.0),
        throwsArgumentError,
      );

      expect(
        () => service.calculateShaftPowerW(electricalPowerW: double.infinity),
        throwsArgumentError,
      );
    });

    test('rejects efficiency outside supported range', () {
      expect(
        () => service.calculateShaftPowerW(
          electricalPowerW: 500.0,
          efficiency: 0.49,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculateShaftPowerW(
          electricalPowerW: 500.0,
          efficiency: 0.99,
        ),
        throwsArgumentError,
      );
    });
  });

  group('PropulsionPowerChainService boundary tests', () {
    final service = PropulsionPowerChainService();

    test('calculates consistent power chain and losses', () {
      final result = service.calculate(
        batteryElectricalPowerW: 500.0,
        escEfficiency: 0.95,
        motorEfficiency: 0.85,
        propellerEfficiency: 0.72,
      );

      expect(result.escOutputPowerW, closeTo(475.0, 1e-9));
      expect(result.motorShaftPowerW, closeTo(403.75, 1e-9));
      expect(result.usefulPropulsivePowerW, closeTo(290.7, 1e-9));
      expect(result.totalPowerLossW, closeTo(209.3, 1e-9));
      expect(result.totalPropulsionEfficiency, closeTo(0.5814, 1e-9));

      expect(
        result.usefulPropulsivePowerW + result.totalPowerLossW,
        closeTo(result.batteryElectricalPowerW, 1e-9),
      );
    });

    test('supports zero electrical power without invalid values', () {
      final result = service.calculate(
        batteryElectricalPowerW: 0.0,
        escEfficiency: 0.95,
        motorEfficiency: 0.85,
        propellerEfficiency: 0.72,
      );

      expect(result.escOutputPowerW, 0.0);
      expect(result.motorShaftPowerW, 0.0);
      expect(result.usefulPropulsivePowerW, 0.0);
      expect(result.totalPowerLossW, 0.0);
    });

    test('rejects negative power and invalid efficiencies', () {
      expect(
        () => service.calculate(
          batteryElectricalPowerW: -1.0,
          escEfficiency: 0.95,
          motorEfficiency: 0.85,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          batteryElectricalPowerW: 500.0,
          escEfficiency: 0.0,
          motorEfficiency: 0.85,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          batteryElectricalPowerW: 500.0,
          escEfficiency: 0.95,
          motorEfficiency: double.nan,
        ),
        throwsArgumentError,
      );
    });
  });

  group('PropulsionLoadService boundary tests', () {
    final service = PropulsionLoadService();

    test('calculates normal finite load ratios and reserves', () {
      final result = service.calculate(
        averageMissionPowerW: 200.0,
        peakMissionPowerW: 350.0,
        continuousMotorPowerW: 450.0,
        maximumMotorPowerW: 550.0,
      );

      expect(result.averageContinuousLoadRatio, closeTo(200 / 450, 1e-9));
      expect(result.peakContinuousLoadRatio, closeTo(350 / 450, 1e-9));
      expect(result.peakMaximumLoadRatio, closeTo(350 / 550, 1e-9));
      expect(result.continuousPowerReserveW, 250.0);
      expect(result.maximumPowerReserveW, 200.0);
      expect(result.exceedsMaximumLimit, isFalse);
    });

    test('detects continuous and maximum power exceedance', () {
      final continuousExceeded = service.calculate(
        averageMissionPowerW: 500.0,
        peakMissionPowerW: 520.0,
        continuousMotorPowerW: 450.0,
        maximumMotorPowerW: 550.0,
      );

      expect(continuousExceeded.exceedsContinuousLimit, isTrue);
      expect(
        continuousExceeded.status,
        PropulsionLoadStatus.continuousLimitExceeded,
      );

      final maximumExceeded = service.calculate(
        averageMissionPowerW: 400.0,
        peakMissionPowerW: 600.0,
        continuousMotorPowerW: 450.0,
        maximumMotorPowerW: 550.0,
      );

      expect(maximumExceeded.exceedsMaximumLimit, isTrue);
      expect(maximumExceeded.status, PropulsionLoadStatus.maximumLimitExceeded);
    });

    test('rejects inconsistent power limits and mission powers', () {
      expect(
        () => service.calculate(
          averageMissionPowerW: 300.0,
          peakMissionPowerW: 200.0,
          continuousMotorPowerW: 450.0,
          maximumMotorPowerW: 550.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          averageMissionPowerW: 200.0,
          peakMissionPowerW: 300.0,
          continuousMotorPowerW: 600.0,
          maximumMotorPowerW: 550.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          averageMissionPowerW: double.nan,
          peakMissionPowerW: 300.0,
          continuousMotorPowerW: 450.0,
          maximumMotorPowerW: 550.0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('PropulsionSystemService boundary tests', () {
    final service = PropulsionSystemService();

    test('calculates a finite integrated propulsion result', () {
      final result = service.calculate(
        averageMissionPowerW: 200.0,
        peakMissionPowerW: 350.0,
        escEfficiency: 0.95,
        motorEfficiency: 0.85,
        propellerEfficiency: 0.72,
        continuousMotorPowerW: 450.0,
        maximumMotorPowerW: 550.0,
      );

      expect(result.totalPropulsionEfficiency, closeTo(0.5814, 1e-9));
      expect(result.averageUsefulPowerReserveW.isFinite, isTrue);
      expect(result.peakUsefulPowerReserveW.isFinite, isTrue);
      expect(result.averagePowerChain.usefulPropulsivePowerW, greaterThan(0.0));
      expect(result.peakPowerChain.usefulPropulsivePowerW, greaterThan(0.0));
    });

    test('propagates invalid efficiency validation', () {
      expect(
        () => service.calculate(
          averageMissionPowerW: 200.0,
          peakMissionPowerW: 350.0,
          escEfficiency: 1.1,
          motorEfficiency: 0.85,
          propellerEfficiency: 0.72,
          continuousMotorPowerW: 450.0,
          maximumMotorPowerW: 550.0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ThrustService boundary tests', () {
    final service = ThrustService();

    test('calculates finite positive thrust and ratio', () {
      final thrust = service.calculate(
        totalElectricalPowerW: 500.0,
        motorCount: 1,
        propellerDiameterInch: 12.0,
        airDensityKgM3: 1.225,
      );

      final ratio = service.thrustToWeight(thrustN: thrust, weightKg: 2.4);

      expect(thrust.isFinite, isTrue);
      expect(thrust, greaterThan(0.0));
      expect(ratio.isFinite, isTrue);
      expect(ratio, greaterThan(0.0));
    });

    test('rejects invalid thrust calculation inputs', () {
      expect(
        () => service.calculate(
          totalElectricalPowerW: 0.0,
          motorCount: 1,
          propellerDiameterInch: 12.0,
          airDensityKgM3: 1.225,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          totalElectricalPowerW: 500.0,
          motorCount: 0,
          propellerDiameterInch: 12.0,
          airDensityKgM3: 1.225,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          totalElectricalPowerW: 500.0,
          motorCount: 1,
          propellerDiameterInch: 0.0,
          airDensityKgM3: 1.225,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          totalElectricalPowerW: 500.0,
          motorCount: 1,
          propellerDiameterInch: 12.0,
          airDensityKgM3: 0.0,
        ),
        throwsArgumentError,
      );
    });

    test('handles invalid thrust-to-weight inputs safely', () {
      expect(service.thrustToWeight(thrustN: 10.0, weightKg: 0.0), 0.0);

      expect(
        () => service.thrustToWeight(thrustN: -1.0, weightKg: 2.4),
        throwsArgumentError,
      );

      expect(service.evaluate(double.nan), 'Geçersiz');
    });
  });

  group('MissionPowerService boundary tests', () {
    final service = MissionPowerService();

    test('calculates fixed-wing mission power', () {
      final result = service.calculate(
        aircraft: buildAircraft(),
        airDensityKgM3: 1.225,
        flightSpeedMs: 15.0,
        dragN: 3.72,
      );

      expect(result.modelName, 'Sabit Kanat Seyir Görev Modeli');
      expect(result.hoverPowerW, 0.0);
      expect(result.cruisePowerW.isFinite, isTrue);
      expect(result.averageMissionPowerW.isFinite, isTrue);
      expect(result.peakMissionPowerW.isFinite, isTrue);
      expect(result.cruisePowerW, greaterThan(0.0));
      expect(
        result.peakMissionPowerW,
        greaterThan(result.averageMissionPowerW),
      );
    });

    test('calculates drone and VTOL mission power', () {
      final drone = service.calculate(
        aircraft: buildAircraft(
          type: 'Drone',
          motorCount: 4,
          motorPowerW: 1200.0,
          propellerDiameterInch: 10.0,
        ),
        airDensityKgM3: 1.225,
        flightSpeedMs: 15.0,
        dragN: 0.0,
      );

      final vtol = service.calculate(
        aircraft: buildAircraft(
          type: 'VTOL',
          motorCount: 4,
          motorPowerW: 1600.0,
          propellerDiameterInch: 12.0,
        ),
        airDensityKgM3: 1.225,
        flightSpeedMs: 15.0,
        dragN: 4.0,
      );

      expect(drone.hoverPowerW, greaterThan(0.0));
      expect(drone.averageMissionPowerW.isFinite, isTrue);
      expect(vtol.hoverPowerW, greaterThan(0.0));
      expect(vtol.cruisePowerW, greaterThan(0.0));
      expect(vtol.averageMissionPowerW.isFinite, isTrue);
    });

    test('rejects unsupported type and invalid common inputs', () {
      expect(
        () => service.calculate(
          aircraft: buildAircraft(type: 'Helikopter'),
          airDensityKgM3: 1.225,
          flightSpeedMs: 15.0,
          dragN: 3.72,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          aircraft: buildAircraft(),
          airDensityKgM3: 0.0,
          flightSpeedMs: 15.0,
          dragN: 3.72,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          aircraft: buildAircraft(),
          airDensityKgM3: 1.225,
          flightSpeedMs: 0.0,
          dragN: 3.72,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          aircraft: buildAircraft(),
          airDensityKgM3: 1.225,
          flightSpeedMs: 15.0,
          dragN: -1.0,
        ),
        throwsArgumentError,
      );
    });
  });
}
