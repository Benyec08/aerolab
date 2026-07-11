import 'package:hive_ce/hive_ce.dart';

import '../entities/aircraft_entity.dart';
import '../hive/hive_boxes.dart';

class AircraftRepository {
  Box<AircraftEntity> get _box {
    if (!Hive.isBoxOpen(HiveBoxes.aircraft)) {
      throw StateError('Aircraft Hive kutusu henüz açılmadı.');
    }

    return Hive.box<AircraftEntity>(HiveBoxes.aircraft);
  }

  List<AircraftEntity> getAll() {
    final aircraft = _box.values.toList();

    aircraft.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return aircraft;
  }

  AircraftEntity? getById(String id) {
    return _box.get(id);
  }

  Future<void> add(AircraftEntity aircraft) async {
    await _box.put(aircraft.id, aircraft);
  }

  Future<void> update(AircraftEntity aircraft) async {
    if (!_box.containsKey(aircraft.id)) {
      throw StateError('Güncellenecek araç veritabanında bulunamadı.');
    }

    final updatedAircraft = aircraft.copyWith(updatedAt: DateTime.now());

    await _box.put(updatedAircraft.id, updatedAircraft);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> duplicate(
    AircraftEntity aircraft, {
    required String copyName,
  }) async {
    final now = DateTime.now();

    final copiedAircraft = aircraft.copyWith(
      id: now.microsecondsSinceEpoch.toString(),
      name: copyName,
      createdAt: now,
      updatedAt: now,
    );

    await add(copiedAircraft);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  bool contains(String id) {
    return _box.containsKey(id);
  }

  int get count {
    return _box.length;
  }
}
