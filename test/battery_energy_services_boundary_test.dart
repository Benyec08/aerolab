import 'package:aerolab/features/analysis/services/battery_chemistry_service.dart';
import 'package:aerolab/features/analysis/services/battery_discharge_curve_service.dart';
import 'package:aerolab/features/analysis/services/battery_electrical_service.dart';
import 'package:aerolab/features/analysis/services/battery_system_service.dart';
import 'package:aerolab/features/analysis/services/flight_time_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BatteryChemistryService boundary tests', () {
    final service = BatteryChemistryService();

    test('returns supported chemistry profiles', () {
      final lipo = service.getProfile('LiPo');
      final liIon = service.getProfile('Li-Ion');
      final lihv = service.getProfile('LiHV');

      expect(lipo.chemistryName, 'LiPo');
      expect(liIon.chemistryName, 'Li-Ion');
      expect(lihv.chemistryName, 'LiHV');

      expect(lipo.nominalPackVoltageV(4), closeTo(14.8, 1e-9));
      expect(liIon.nominalPackVoltageV(4), closeTo(14.4, 1e-9));
      expect(lihv.nominalPackVoltageV(4), closeTo(15.2, 1e-9));
    });

    test('normalizes chemistry names', () {
      expect(service.getProfile(' li-ion ').chemistryName, 'Li-Ion');
      expect(service.getProfile('LI PO').chemistryName, 'LiPo');
      expect(service.getProfile('lihv').chemistryName, 'LiHV');
    });

    test('rejects unsupported chemistry', () {
      expect(() => service.getProfile('NiMH'), throwsArgumentError);
    });

    test('rejects non-positive cell count', () {
      final profile = service.getProfile('LiPo');

      expect(() => profile.fullPackVoltageV(0), throwsArgumentError);
      expect(() => profile.nominalPackVoltageV(-1), throwsArgumentError);
      expect(() => profile.minimumSafePackVoltageV(0), throwsArgumentError);
    });
  });

  group('BatteryDischargeCurveService boundary tests', () {
    final chemistryService = BatteryChemistryService();
    final service = BatteryDischargeCurveService();

    test('calculates finite positive usable energy', () {
      final result = service.calculate(
        chemistryProfile: chemistryService.getProfile('LiPo'),
        cellCount: 4,
        capacityAh: 8.0,
        reserveFraction: 0.15,
      );

      expect(result.nominalEnergyWh, closeTo(118.4, 1e-9));
      expect(result.curveIntegratedEnergyWh.isFinite, isTrue);
      expect(result.correctedUsableEnergyWh.isFinite, isTrue);
      expect(result.averageUsablePackVoltageV.isFinite, isTrue);

      expect(result.curveIntegratedEnergyWh, greaterThan(0.0));
      expect(result.correctedUsableEnergyWh, greaterThan(0.0));
      expect(result.correctedUsableEnergyWh, lessThan(result.nominalEnergyWh));
      expect(result.usableStateOfChargeFraction, closeTo(0.85, 1e-9));
      expect(result.usableEnergyFraction, inInclusiveRange(0.0, 1.0));
    });

    test('returns chemistry voltage at state-of-charge limits', () {
      expect(
        service.cellVoltageAtStateOfCharge(
          chemistryName: 'LiPo',
          stateOfChargeFraction: 1.0,
        ),
        closeTo(4.20, 1e-9),
      );

      expect(
        service.cellVoltageAtStateOfCharge(
          chemistryName: 'LiPo',
          stateOfChargeFraction: 0.0,
        ),
        closeTo(3.30, 1e-9),
      );
    });

    test('rejects invalid state of charge', () {
      expect(
        () => service.cellVoltageAtStateOfCharge(
          chemistryName: 'LiPo',
          stateOfChargeFraction: -0.01,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.cellVoltageAtStateOfCharge(
          chemistryName: 'LiPo',
          stateOfChargeFraction: 1.01,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.cellVoltageAtStateOfCharge(
          chemistryName: 'LiPo',
          stateOfChargeFraction: double.nan,
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid calculation inputs', () {
      final profile = chemistryService.getProfile('LiPo');

      expect(
        () => service.calculate(
          chemistryProfile: profile,
          cellCount: 0,
          capacityAh: 8.0,
          reserveFraction: 0.15,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          chemistryProfile: profile,
          cellCount: 4,
          capacityAh: 0.0,
          reserveFraction: 0.15,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          chemistryProfile: profile,
          cellCount: 4,
          capacityAh: 8.0,
          reserveFraction: 1.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          chemistryProfile: profile,
          cellCount: 4,
          capacityAh: 8.0,
          reserveFraction: 0.15,
          batteryHealth: 0.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          chemistryProfile: profile,
          cellCount: 4,
          capacityAh: 8.0,
          reserveFraction: 0.15,
          integrationSteps: 9,
        ),
        throwsArgumentError,
      );
    });
  });

  group('BatteryElectricalService boundary tests', () {
    final service = BatteryElectricalService();

    test('zero requested power produces zero current and sag', () {
      final result = service.calculate(
        requestedPowerW: 0.0,
        openCircuitVoltageV: 14.8,
        packInternalResistanceOhm: 0.016,
        capacityAh: 8.0,
      );

      expect(result.currentA, 0.0);
      expect(result.voltageSagV, 0.0);
      expect(result.loadedVoltageV, 14.8);
      expect(result.canDeliverRequestedPower, isTrue);
    });

    test('valid power request remains finite and positive', () {
      final result = service.calculate(
        requestedPowerW: 100.0,
        openCircuitVoltageV: 14.8,
        packInternalResistanceOhm: 0.016,
        capacityAh: 8.0,
      );

      expect(result.currentA.isFinite, isTrue);
      expect(result.loadedVoltageV.isFinite, isTrue);
      expect(result.voltageSagV.isFinite, isTrue);
      expect(result.cRate.isFinite, isTrue);

      expect(result.currentA, greaterThan(0.0));
      expect(result.loadedVoltageV, greaterThan(0.0));
      expect(result.loadedVoltageV, lessThan(14.8));
      expect(result.canDeliverRequestedPower, isTrue);
    });

    test('reports unavailable power above electrical maximum', () {
      final result = service.calculate(
        requestedPowerW: 5000.0,
        openCircuitVoltageV: 14.8,
        packInternalResistanceOhm: 0.05,
        capacityAh: 8.0,
      );

      expect(result.canDeliverRequestedPower, isFalse);
      expect(result.maximumDeliverablePowerW.isFinite, isTrue);
      expect(result.loadedVoltageV, 0.0);
    });

    test('rejects invalid electrical inputs', () {
      expect(
        () => service.calculate(
          requestedPowerW: -1.0,
          openCircuitVoltageV: 14.8,
          packInternalResistanceOhm: 0.016,
          capacityAh: 8.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          requestedPowerW: 100.0,
          openCircuitVoltageV: 0.0,
          packInternalResistanceOhm: 0.016,
          capacityAh: 8.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          requestedPowerW: 100.0,
          openCircuitVoltageV: 14.8,
          packInternalResistanceOhm: -0.01,
          capacityAh: 8.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          requestedPowerW: 100.0,
          openCircuitVoltageV: 14.8,
          packInternalResistanceOhm: 0.016,
          capacityAh: 0.0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('BatterySystemService boundary tests', () {
    final service = BatterySystemService();

    test('calculates a finite battery system result', () {
      final result = service.calculate(
        batteryType: 'LiPo',
        cellCount: 4,
        capacityMah: 8000.0,
        cellInternalResistanceMilliOhm: 4.0,
        averageMissionPowerW: 70.5,
        peakMissionPowerW: 319.8,
      );

      expect(result.nominalEnergyWh.isFinite, isTrue);
      expect(result.realUsableEnergyWh.isFinite, isTrue);
      expect(result.estimatedFlightTimeMinutes.isFinite, isTrue);
      expect(result.loadEfficiencyFactor.isFinite, isTrue);

      expect(result.nominalEnergyWh, greaterThan(0.0));
      expect(result.realUsableEnergyWh, greaterThan(0.0));
      expect(result.estimatedFlightTimeMinutes, greaterThan(0.0));
      expect(result.realUsableEnergyWh, lessThan(result.nominalEnergyWh));
      expect(result.loadEfficiencyFactor, inInclusiveRange(0.0, 1.0));
    });

    test('uses chemistry default resistance when zero is supplied', () {
      final result = service.calculate(
        batteryType: 'LiPo',
        cellCount: 4,
        capacityMah: 8000.0,
        cellInternalResistanceMilliOhm: 0.0,
        averageMissionPowerW: 70.5,
        peakMissionPowerW: 319.8,
      );

      expect(result.cellInternalResistanceMilliOhm, 4.0);
      expect(result.packInternalResistanceOhm, closeTo(0.016, 1e-9));
    });

    test('rejects peak power lower than average power', () {
      expect(
        () => service.calculate(
          batteryType: 'LiPo',
          cellCount: 4,
          capacityMah: 8000.0,
          cellInternalResistanceMilliOhm: 4.0,
          averageMissionPowerW: 300.0,
          peakMissionPowerW: 200.0,
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid battery-system inputs', () {
      expect(
        () => service.calculate(
          batteryType: 'LiPo',
          cellCount: 0,
          capacityMah: 8000.0,
          cellInternalResistanceMilliOhm: 4.0,
          averageMissionPowerW: 70.5,
          peakMissionPowerW: 319.8,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          batteryType: 'LiPo',
          cellCount: 4,
          capacityMah: 0.0,
          cellInternalResistanceMilliOhm: 4.0,
          averageMissionPowerW: 70.5,
          peakMissionPowerW: 319.8,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          batteryType: 'LiPo',
          cellCount: 4,
          capacityMah: 8000.0,
          cellInternalResistanceMilliOhm: -1.0,
          averageMissionPowerW: 70.5,
          peakMissionPowerW: 319.8,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          batteryType: 'LiPo',
          cellCount: 4,
          capacityMah: 8000.0,
          cellInternalResistanceMilliOhm: 4.0,
          averageMissionPowerW: 0.0,
          peakMissionPowerW: 319.8,
        ),
        throwsArgumentError,
      );
    });
  });

  group('FlightTimeService boundary tests', () {
    final service = FlightTimeService();

    test('calculates expected finite flight time', () {
      final result = service.calculateDetailed(
        batteryCapacityMah: 8000.0,
        batteryVoltageV: 14.8,
        averagePowerConsumptionW: 70.5,
      );

      expect(result.nominalCapacityAh, 8.0);
      expect(result.nominalEnergyWh, closeTo(118.4, 1e-9));
      expect(result.effectiveEnergyWh, closeTo(100.64, 1e-9));
      expect(result.estimatedAverageCurrentA, closeTo(4.7635, 0.0001));
      expect(result.estimatedFlightTimeMinutes, closeTo(85.65, 0.01));

      expect(result.effectiveEnergyWh.isFinite, isTrue);
      expect(result.estimatedFlightTimeMinutes.isFinite, isTrue);
    });

    test('rejects invalid energy inputs and correction factors', () {
      expect(
        () => service.calculateMinutes(
          batteryCapacityMah: 0.0,
          batteryVoltageV: 14.8,
          averagePowerConsumptionW: 70.5,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculateMinutes(
          batteryCapacityMah: 8000.0,
          batteryVoltageV: 0.0,
          averagePowerConsumptionW: 70.5,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculateMinutes(
          batteryCapacityMah: 8000.0,
          batteryVoltageV: 14.8,
          averagePowerConsumptionW: 0.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculateMinutes(
          batteryCapacityMah: 8000.0,
          batteryVoltageV: 14.8,
          averagePowerConsumptionW: 70.5,
          reserveFraction: 1.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculateMinutes(
          batteryCapacityMah: 8000.0,
          batteryVoltageV: 14.8,
          averagePowerConsumptionW: 70.5,
          batteryHealth: double.nan,
        ),
        throwsArgumentError,
      );
    });
  });
}
