import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/entities/aircraft_entity.dart';
import 'data/hive/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AircraftEntityAdapter());
  }

  await Hive.openBox<AircraftEntity>(HiveBoxes.aircraft);

  runApp(const AeroLabApp());
}
