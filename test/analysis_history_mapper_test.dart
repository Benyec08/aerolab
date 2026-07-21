import 'package:aerolab/data/entities/analysis_history_entity.dart';
import 'package:aerolab/data/mappers/analysis_history_mapper.dart';
import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/aircraft_mass_station.dart';
import 'package:aerolab/features/analysis/models/environment.dart';
import 'package:aerolab/features/analysis/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = AnalysisHistoryMapper();

  Aircraft createAircraft() {
    return Aircraft(
      name: 'Sprint 17A Round Trip Uçağı',
      type: 'Sabit Kanat',
      weightKg: 5.0,
      wingAreaM2: 1.2,
      wingSpanM: 2.4,
      motorCount: 1,
      motorPowerW: 1800.0,
      propellerDiameterInch: 16.0,
      batteryCapacityMah: 10000.0,
      batteryVoltageV: 22.2,
      batteryType: 'LiPo',
      batteryCellCount: 6,
      motorComponentId: 'motor-test',
      propellerComponentId: 'prop-test',
      batteryComponentId: 'battery-test',
      escComponentId: 'esc-test',
      motorPropellerCombinationId: 'combo-test',
      cellInternalResistanceMilliOhm: 4.0,
      cruiseSpeedMs: 20.0,
      zeroLiftDragCoefficient: 0.032,
      maxLiftCoefficient: 1.5,
      oswaldEfficiencyFactor: 0.82,
      escEfficiency: 0.95,
      motorEfficiency: 0.88,
      continuousMotorPowerW: 1600.0,
      maximumMotorPowerW: 2200.0,
      massStations: const [
        AircraftMassStation(
          name: 'Burun ekipmanı',
          massKg: 1.0,
          armFromDatumM: 0.25,
        ),
        AircraftMassStation(name: 'Gövde', massKg: 2.5, armFromDatumM: 0.70),
        AircraftMassStation(name: 'Batarya', massKg: 1.5, armFromDatumM: 0.95),
      ],
      meanAerodynamicChordM: 0.45,
      macLeadingEdgeFromDatumM: 0.55,
      neutralPointPercentMac: 40.0,
      minimumCgPercentMac: 20.0,
      maximumCgPercentMac: 35.0,
      maximumOperatingSpeedMs: 35.0,
      positiveLimitLoadFactor: 3.8,
      negativeLimitLoadFactor: -1.5,
    );
  }

  const environment = Environment(
    altitudeM: 1200.0,
    temperatureC: 25.0,
    pressureHpa: 880.0,
    humidityPercent: 60.0,
    windSpeedKmh: 15.0,
    windDirection: 'Karşıdan',
  );

  test('aircraft, environment and result survive JSON round trip', () {
    final aircraft = createAircraft();
    final result = AnalysisService().analyze(aircraft, environment);

    final entity = mapper.toEntity(
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    final restoredAircraft = mapper.restoreAircraft(entity);
    final restoredEnvironment = mapper.restoreEnvironment(entity);
    final restoredResult = mapper.restoreResult(entity);

    expect(
      mapper.aircraftToMap(restoredAircraft),
      equals(mapper.aircraftToMap(aircraft)),
    );
    expect(
      mapper.environmentToMap(restoredEnvironment),
      equals(mapper.environmentToMap(environment)),
    );
    expect(
      mapper.resultToMap(restoredResult),
      equals(mapper.resultToMap(result)),
    );
  });

  test('stored summary fields match the analyzed aircraft', () {
    final aircraft = createAircraft();
    final result = AnalysisService().analyze(aircraft, environment);

    final entity = mapper.toEntity(
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    expect(entity.aircraftName, aircraft.name);
    expect(entity.aircraftType, aircraft.type);
    expect(entity.dataVersion, 1);
    expect(entity.id, isNotEmpty);
  });

  test('invalid snapshot JSON throws FormatException', () {
    final invalidEntity = AnalysisHistoryEntity(
      id: 'invalid',
      createdAt: DateTime(2026, 7, 21),
      aircraftName: 'Bozuk Kayıt',
      aircraftType: 'Sabit Kanat',
      aircraftDataJson: '[]',
      environmentDataJson: '{}',
      resultDataJson: '{}',
    );

    expect(
      () => mapper.restoreAircraft(invalidEntity),
      throwsA(isA<FormatException>()),
    );
  });
}
