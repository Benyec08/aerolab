import '../../features/analysis/models/aircraft.dart';
import '../entities/aircraft_entity.dart';
import '../mappers/aircraft_mapper.dart';
import '../repositories/aircraft_repository.dart';

class AircraftService {
  final AircraftRepository _repository;

  AircraftService({AircraftRepository? repository})
    : _repository = repository ?? AircraftRepository();

  List<AircraftEntity> getAllAircraft() {
    return _repository.getAll();
  }

  AircraftEntity? getAircraftById(String id) {
    return _repository.getById(id);
  }

  int get aircraftCount => _repository.count;

  Future<void> ensureInitialAircraft() async {
    if (_repository.count > 0) {
      return;
    }

    final initialAircraft = [
      AircraftEntity.create(
        name: 'F16 Prototype',
        type: 'Sabit Kanat',
        weightKg: 2.35,
        wingAreaM2: 0.46,
        wingSpanM: 1.40,
        motorCount: 1,
        motorPowerW: 1200,
        propellerDiameterInch: 14,
        batteryCapacityMah: 5000,
        batteryVoltageV: 22.2,
        batteryType: 'LiPo',
        batteryCellCount: 6,
        batteryDescription: '6S LiPo',
      ),
      AircraftEntity.create(
        name: 'UAV-X Drone',
        type: 'Drone',
        weightKg: 1.20,
        wingAreaM2: 0,
        wingSpanM: 0,
        motorCount: 4,
        motorPowerW: 800,
        propellerDiameterInch: 10,
        batteryCapacityMah: 5200,
        batteryVoltageV: 14.8,
        batteryType: 'LiPo',
        batteryCellCount: 4,
        batteryDescription: '4S LiPo',
      ),
      AircraftEntity.create(
        name: 'VTOL Alpha',
        type: 'VTOL',
        weightKg: 3.10,
        wingAreaM2: 0.55,
        wingSpanM: 1.80,
        motorCount: 4,
        motorPowerW: 1600,
        propellerDiameterInch: 12,
        batteryCapacityMah: 10000,
        batteryVoltageV: 21.6,
        batteryType: 'Li-Ion',
        batteryCellCount: 6,
        batteryDescription: '6S Li-Ion',
      ),
    ];

    for (final aircraft in initialAircraft) {
      await _repository.add(aircraft);
    }
  }

  Future<AircraftEntity> createAircraft(Map<String, dynamic> formData) async {
    final aircraft = AircraftEntity.fromMap(formData);

    await _repository.add(aircraft);

    return aircraft;
  }

  Future<AircraftEntity> updateAircraft({
    required AircraftEntity currentAircraft,
    required Map<String, dynamic> formData,
  }) async {
    final updatedAircraft = AircraftEntity.fromMap({
      ...formData,
      'id': currentAircraft.id,
      'created': currentAircraft.createdAt,
      'updated': DateTime.now(),
    });

    await _repository.update(updatedAircraft);

    return updatedAircraft;
  }

  Future<AircraftEntity> duplicateAircraft(AircraftEntity aircraft) async {
    final copyName = _createUniqueCopyName(aircraft.name);

    await _repository.duplicate(aircraft, copyName: copyName);

    final copiedAircraft = _repository.getAll().firstWhere(
      (item) => item.name == copyName,
    );

    return copiedAircraft;
  }

  Future<void> deleteAircraft(String id) async {
    await _repository.delete(id);
  }

  Aircraft toEngineeringModel(AircraftEntity entity) {
    return AircraftMapper.toModel(entity);
  }

  String _createUniqueCopyName(String originalName) {
    final aircraft = _repository.getAll();
    final baseName = '$originalName Kopya';

    if (!aircraft.any((item) => item.name == baseName)) {
      return baseName;
    }

    var copyNumber = 2;

    while (aircraft.any((item) => item.name == '$baseName $copyNumber')) {
      copyNumber++;
    }

    return '$baseName $copyNumber';
  }
}
