import 'dart:io';

import 'package:aerolab/data/entities/aircraft_entity.dart';
import 'package:aerolab/data/hive/hive_boxes.dart';
import 'package:aerolab/data/mappers/aircraft_mapper.dart';
import 'package:aerolab/data/repositories/aircraft_repository.dart';
import 'package:aerolab/data/services/aircraft_service.dart';
import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/aircraft_mass_station.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

void main() {
  late Directory temporaryDirectory;
  late AircraftRepository repository;
  late AircraftService service;

  Future<void> openAircraftBox() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AircraftEntityAdapter());
    }

    if (!Hive.isBoxOpen(HiveBoxes.aircraft)) {
      await Hive.openBox<AircraftEntity>(HiveBoxes.aircraft);
    }
  }

  setUpAll(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'aerolab_sprint16d_',
    );

    Hive.init(temporaryDirectory.path);
    await openAircraftBox();

    repository = AircraftRepository();
    service = AircraftService(repository: repository);
  });

  setUp(() async {
    await openAircraftBox();
    await repository.clearAll();
  });

  tearDownAll(() async {
    await Hive.close();

    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  Map<String, dynamic> createFormData({
    String name = 'Persistence Test Aircraft',
    String type = 'Sabit Kanat',
    double weightKg = 2.4,
  }) {
    return {
      'name': name,
      'type': type,
      'weight': weightKg,
      'wingArea': 0.60,
      'wingSpan': 2.0,
      'motorCount': 1,
      'motorPower': 500.0,
      'propellerDiameter': 12.0,
      'batteryCapacity': 8000.0,
      'batteryVoltage': 14.8,
      'batteryType': 'LiPo',
      'batteryCellCount': 4,
      'battery': '4S LiPo',
      'cruiseSpeedMs': 15.0,
      'zeroLiftDragCoefficient': 0.03,
      'maxLiftCoefficient': 1.4,
      'oswaldEfficiencyFactor': 0.80,
      'escEfficiency': 0.95,
      'motorEfficiency': 0.85,
      'continuousMotorPowerW': 450.0,
      'maximumMotorPowerW': 550.0,
      'cellInternalResistanceMilliOhm': 4.0,
      'massStationsJson':
          '[{"name":"Motor Sistemi","massKg":0.5,"armFromDatumM":0.1},'
          '{"name":"Batarya","massKg":0.8,"armFromDatumM":0.2},'
          '{"name":"Gövde","massKg":1.1,"armFromDatumM":0.3}]',
      'meanAerodynamicChordM': 0.40,
      'macLeadingEdgeFromDatumM': 0.15,
      'neutralPointPercentMac': 40.0,
      'minimumCgPercentMac': 15.0,
      'maximumCgPercentMac': 35.0,
      'maximumOperatingSpeedMs': 25.0,
      'positiveLimitLoadFactor': 3.8,
      'negativeLimitLoadFactor': -1.5,
    };
  }

  AircraftEntity createEntity({
    String id = 'aircraft-001',
    String name = 'Repository Aircraft',
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime(2026, 7, 20, 12);

    return AircraftEntity(
      id: id,
      name: name,
      type: 'Sabit Kanat',
      weightKg: 2.4,
      wingAreaM2: 0.60,
      wingSpanM: 2.0,
      motorCount: 1,
      motorPowerW: 500.0,
      propellerDiameterInch: 12.0,
      batteryCapacityMah: 8000.0,
      batteryVoltageV: 14.8,
      batteryType: 'LiPo',
      batteryCellCount: 4,
      batteryDescription: '4S LiPo',
      createdAt: timestamp,
      updatedAt: timestamp,
      cruiseSpeedMs: 15.0,
      zeroLiftDragCoefficient: 0.03,
      maxLiftCoefficient: 1.4,
      oswaldEfficiencyFactor: 0.80,
      escEfficiency: 0.95,
      motorEfficiency: 0.85,
      continuousMotorPowerW: 450.0,
      maximumMotorPowerW: 550.0,
      cellInternalResistanceMilliOhm: 4.0,
    );
  }

  group('AircraftEntity persistence boundaries', () {
    test('legacy map uses safe defaults for newer engineering fields', () {
      final entity = AircraftEntity.fromMap({
        'id': 'legacy-001',
        'name': 'Legacy Aircraft',
        'type': 'Sabit Kanat',
        'weight': '2,4',
        'wingArea': '0,60',
        'wingSpan': '2,0',
        'motorCount': '1',
        'motorPower': '500',
        'propellerDiameter': '12',
        'batteryCapacity': '8000',
        'batteryVoltage': '14,8',
        'batteryType': 'LiPo',
        'batteryCellCount': '4',
      });

      expect(entity.cruiseSpeedMs, 15.0);
      expect(entity.zeroLiftDragCoefficient, 0.03);
      expect(entity.maxLiftCoefficient, 1.4);
      expect(entity.oswaldEfficiencyFactor, 0.80);
      expect(entity.escEfficiency, 0.95);
      expect(entity.motorEfficiency, 0.85);

      expect(entity.continuousMotorPowerW, 500.0);
      expect(entity.maximumMotorPowerW, 500.0);
      expect(entity.cellInternalResistanceMilliOhm, 0.0);

      expect(entity.massStationsJson, '[]');
      expect(entity.meanAerodynamicChordM, 0.0);
      expect(entity.macLeadingEdgeFromDatumM, 0.0);
      expect(entity.neutralPointPercentMac, 40.0);
      expect(entity.minimumCgPercentMac, 20.0);
      expect(entity.maximumCgPercentMac, 35.0);
      expect(entity.maximumOperatingSpeedMs, 25.0);
      expect(entity.positiveLimitLoadFactor, 3.8);
      expect(entity.negativeLimitLoadFactor, -1.5);
    });

    test('map round trip preserves all current persistence fields', () {
      final original = AircraftEntity.fromMap({
        ...createFormData(),
        'id': 'round-trip-001',
        'motorComponentId': 'motor-001',
        'propellerComponentId': 'propeller-001',
        'batteryComponentId': 'battery-001',
        'escComponentId': 'esc-001',
        'motorPropellerCombinationId': 'combination-001',
        'created': DateTime(2026, 7, 20, 12),
        'updated': DateTime(2026, 7, 20, 13),
      });

      final restored = AircraftEntity.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.type, original.type);
      expect(restored.weightKg, original.weightKg);
      expect(restored.wingAreaM2, original.wingAreaM2);
      expect(restored.wingSpanM, original.wingSpanM);
      expect(restored.motorCount, original.motorCount);
      expect(restored.motorPowerW, original.motorPowerW);
      expect(restored.batteryCapacityMah, original.batteryCapacityMah);
      expect(restored.batteryVoltageV, original.batteryVoltageV);
      expect(restored.batteryCellCount, original.batteryCellCount);

      expect(restored.cruiseSpeedMs, original.cruiseSpeedMs);
      expect(
        restored.zeroLiftDragCoefficient,
        original.zeroLiftDragCoefficient,
      );
      expect(restored.maxLiftCoefficient, original.maxLiftCoefficient);
      expect(restored.oswaldEfficiencyFactor, original.oswaldEfficiencyFactor);
      expect(restored.escEfficiency, original.escEfficiency);
      expect(restored.motorEfficiency, original.motorEfficiency);
      expect(restored.continuousMotorPowerW, original.continuousMotorPowerW);
      expect(restored.maximumMotorPowerW, original.maximumMotorPowerW);
      expect(
        restored.cellInternalResistanceMilliOhm,
        original.cellInternalResistanceMilliOhm,
      );

      expect(restored.motorComponentId, original.motorComponentId);
      expect(restored.propellerComponentId, original.propellerComponentId);
      expect(restored.batteryComponentId, original.batteryComponentId);
      expect(restored.escComponentId, original.escComponentId);
      expect(
        restored.motorPropellerCombinationId,
        original.motorPropellerCombinationId,
      );

      expect(restored.massStationsJson, original.massStationsJson);
      expect(restored.meanAerodynamicChordM, original.meanAerodynamicChordM);
      expect(
        restored.macLeadingEdgeFromDatumM,
        original.macLeadingEdgeFromDatumM,
      );
      expect(restored.neutralPointPercentMac, original.neutralPointPercentMac);
      expect(restored.minimumCgPercentMac, original.minimumCgPercentMac);
      expect(restored.maximumCgPercentMac, original.maximumCgPercentMac);
      expect(
        restored.maximumOperatingSpeedMs,
        original.maximumOperatingSpeedMs,
      );
      expect(
        restored.positiveLimitLoadFactor,
        original.positiveLimitLoadFactor,
      );
      expect(
        restored.negativeLimitLoadFactor,
        original.negativeLimitLoadFactor,
      );
    });

    test('copyWith preserves identity unless explicitly replaced', () {
      final original = createEntity();

      final copy = original.copyWith(name: 'Updated Name', motorPowerW: 650.0);

      expect(copy.id, original.id);
      expect(copy.createdAt, original.createdAt);
      expect(copy.name, 'Updated Name');
      expect(copy.motorPowerW, 650.0);
      expect(copy.continuousMotorPowerW, original.continuousMotorPowerW);
      expect(copy.maximumMotorPowerW, original.maximumMotorPowerW);
      expect(copy.updatedAt.isBefore(original.updatedAt), isFalse);
    });
  });

  group('AircraftMapper persistence boundaries', () {
    test('model and entity round trip preserves stability inputs', () {
      final original = Aircraft(
        name: 'Stability Mapping Aircraft',
        type: 'Sabit Kanat',
        weightKg: 2.4,
        wingAreaM2: 0.60,
        wingSpanM: 2.0,
        motorCount: 1,
        motorPowerW: 500.0,
        propellerDiameterInch: 12.0,
        batteryCapacityMah: 8000.0,
        batteryVoltageV: 14.8,
        batteryType: 'LiPo',
        batteryCellCount: 4,
        cruiseSpeedMs: 15.0,
        zeroLiftDragCoefficient: 0.03,
        maxLiftCoefficient: 1.4,
        oswaldEfficiencyFactor: 0.80,
        escEfficiency: 0.95,
        motorEfficiency: 0.85,
        continuousMotorPowerW: 450.0,
        maximumMotorPowerW: 550.0,
        massStations: const [
          AircraftMassStation(
            name: 'Motor Sistemi',
            massKg: 0.5,
            armFromDatumM: 0.1,
          ),
          AircraftMassStation(name: 'Batarya', massKg: 0.8, armFromDatumM: 0.2),
          AircraftMassStation(name: 'Gövde', massKg: 1.1, armFromDatumM: 0.3),
        ],
        meanAerodynamicChordM: 0.40,
        macLeadingEdgeFromDatumM: 0.15,
        neutralPointPercentMac: 40.0,
        minimumCgPercentMac: 15.0,
        maximumCgPercentMac: 35.0,
        maximumOperatingSpeedMs: 25.0,
        positiveLimitLoadFactor: 3.8,
        negativeLimitLoadFactor: -1.5,
      );

      final entity = AircraftMapper.toEntity(original, id: 'mapper-round-trip');
      final restored = AircraftMapper.toModel(entity);

      expect(restored.massStations, hasLength(3));
      expect(restored.massStations[0].name, 'Motor Sistemi');
      expect(restored.massStations[0].massKg, 0.5);
      expect(restored.massStations[0].armFromDatumM, 0.1);
      expect(restored.massStations[1].name, 'Batarya');
      expect(restored.massStations[2].name, 'Gövde');

      expect(restored.meanAerodynamicChordM, original.meanAerodynamicChordM);
      expect(
        restored.macLeadingEdgeFromDatumM,
        original.macLeadingEdgeFromDatumM,
      );
      expect(restored.neutralPointPercentMac, original.neutralPointPercentMac);
      expect(restored.minimumCgPercentMac, original.minimumCgPercentMac);
      expect(restored.maximumCgPercentMac, original.maximumCgPercentMac);
      expect(
        restored.maximumOperatingSpeedMs,
        original.maximumOperatingSpeedMs,
      );
      expect(
        restored.positiveLimitLoadFactor,
        original.positiveLimitLoadFactor,
      );
      expect(
        restored.negativeLimitLoadFactor,
        original.negativeLimitLoadFactor,
      );
    });

    test('malformed mass-station JSON is restored as an empty list', () {
      final entity = createEntity().copyWith(massStationsJson: '{invalid-json');

      final model = AircraftMapper.toModel(entity);

      expect(model.massStations, isEmpty);
      expect(model.hasStabilityInputs, isFalse);
    });

    test('invalid mass stations are discarded during decoding', () {
      final entity = createEntity().copyWith(
        massStationsJson:
            '[{"name":"Valid","massKg":1.0,"armFromDatumM":0.2},'
            '{"name":"","massKg":0.0,"armFromDatumM":0.3}]',
      );

      final model = AircraftMapper.toModel(entity);

      expect(model.massStations, hasLength(1));
      expect(model.massStations.single.name, 'Valid');
    });
  });

  group('AircraftRepository Hive persistence', () {
    test('adds, reads and counts entities', () async {
      final aircraft = createEntity();

      await repository.add(aircraft);

      expect(repository.count, 1);
      expect(repository.contains(aircraft.id), isTrue);
      expect(repository.getById(aircraft.id), isNotNull);
      expect(repository.getById(aircraft.id)?.name, aircraft.name);
    });

    test('getAll sorts newest aircraft first', () async {
      final older = createEntity(
        id: 'older',
        name: 'Older',
        createdAt: DateTime(2026, 7, 19),
      );
      final newer = createEntity(
        id: 'newer',
        name: 'Newer',
        createdAt: DateTime(2026, 7, 20),
      );

      await repository.add(older);
      await repository.add(newer);

      final all = repository.getAll();

      expect(all, hasLength(2));
      expect(all.first.id, 'newer');
      expect(all.last.id, 'older');
    });

    test('updates existing entity and preserves its key', () async {
      final aircraft = createEntity();
      await repository.add(aircraft);

      final changed = aircraft.copyWith(
        name: 'Updated Aircraft',
        motorPowerW: 700.0,
      );

      await repository.update(changed);

      final stored = repository.getById(aircraft.id);

      expect(repository.count, 1);
      expect(stored?.id, aircraft.id);
      expect(stored?.name, 'Updated Aircraft');
      expect(stored?.motorPowerW, 700.0);
    });

    test('rejects update when entity does not exist', () async {
      final missing = createEntity(id: 'missing');

      expect(() => repository.update(missing), throwsA(isA<StateError>()));
    });

    test('deletes entity by identifier', () async {
      final aircraft = createEntity();
      await repository.add(aircraft);

      await repository.delete(aircraft.id);

      expect(repository.count, 0);
      expect(repository.getById(aircraft.id), isNull);
    });

    test('duplicates entity with a new identifier and timestamp', () async {
      final original = createEntity();
      await repository.add(original);

      await repository.duplicate(
        original,
        copyName: 'Repository Aircraft Kopya',
      );

      final all = repository.getAll();

      expect(all, hasLength(2));

      final copied = all.firstWhere(
        (item) => item.name == 'Repository Aircraft Kopya',
      );

      expect(copied.id, isNot(original.id));
      expect(copied.createdAt.isBefore(original.createdAt), isFalse);
      expect(copied.weightKg, original.weightKg);
      expect(copied.motorPowerW, original.motorPowerW);
    });

    test('throws StateError while aircraft box is closed', () async {
      await Hive.box<AircraftEntity>(HiveBoxes.aircraft).close();

      try {
        expect(() => repository.getAll(), throwsA(isA<StateError>()));
      } finally {
        await openAircraftBox();
      }
    });
  });

  group('AircraftService persistence workflow', () {
    test('creates and converts an aircraft to engineering model', () async {
      final created = await service.createAircraft(createFormData());

      expect(repository.count, 1);
      expect(repository.getById(created.id), isNotNull);

      final model = service.toEngineeringModel(created);

      expect(model.name, created.name);
      expect(model.type, created.type);
      expect(model.massStations, hasLength(3));
      expect(model.hasStabilityInputs, isTrue);
      expect(model.hasFlightEnvelopeInputs, isTrue);
    });

    test('updates while preserving id and created timestamp', () async {
      final created = await service.createAircraft(createFormData());
      final originalCreatedAt = created.createdAt;

      final updated = await service.updateAircraft(
        currentAircraft: created,
        formData: createFormData(
          name: 'Updated Service Aircraft',
          weightKg: 3.0,
        ),
      );

      expect(updated.id, created.id);
      expect(updated.createdAt, originalCreatedAt);
      expect(updated.name, 'Updated Service Aircraft');
      expect(updated.weightKg, 3.0);
      expect(repository.count, 1);
    });

    test('generates unique copy names', () async {
      final created = await service.createAircraft(
        createFormData(name: 'Copy Source'),
      );

      final firstCopy = await service.duplicateAircraft(created);
      final secondCopy = await service.duplicateAircraft(created);
      final thirdCopy = await service.duplicateAircraft(created);

      expect(firstCopy.name, 'Copy Source Kopya');
      expect(secondCopy.name, 'Copy Source Kopya 2');
      expect(thirdCopy.name, 'Copy Source Kopya 3');
      expect(repository.count, 4);
    });

    test('deletes aircraft through service', () async {
      final created = await service.createAircraft(createFormData());

      await service.deleteAircraft(created.id);

      expect(service.aircraftCount, 0);
      expect(service.getAircraftById(created.id), isNull);
    });

    test('seeds initial aircraft only when repository is empty', () async {
      await service.ensureInitialAircraft();

      expect(service.aircraftCount, 3);

      final namesAfterFirstSeed = service
          .getAllAircraft()
          .map((aircraft) => aircraft.name)
          .toSet();

      expect(
        namesAfterFirstSeed,
        containsAll(<String>{'F16 Prototype', 'UAV-X Drone', 'VTOL Alpha'}),
      );

      await service.ensureInitialAircraft();

      expect(service.aircraftCount, 3);
    });

    test('does not seed defaults into non-empty repository', () async {
      await repository.add(createEntity(id: 'custom', name: 'Custom Aircraft'));

      await service.ensureInitialAircraft();

      expect(service.aircraftCount, 1);
      expect(service.getAllAircraft().single.name, 'Custom Aircraft');
    });
  });
}
