import 'dart:io';

import 'package:aerolab/data/entities/analysis_history_entity.dart';
import 'package:aerolab/data/hive/hive_boxes.dart';
import 'package:aerolab/data/services/analysis_history_service.dart';
import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/environment.dart';
import 'package:aerolab/features/analysis/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'aerolab_analysis_history_persistence_test_',
    );

    Hive.init(tempDirectory.path);

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AnalysisHistoryEntityAdapter());
    }

    await Hive.openBox<AnalysisHistoryEntity>(HiveBoxes.analysisHistory);
  });

  tearDown(() async {
    await Hive.close();

    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  Aircraft createAircraft() {
    return Aircraft(
      name: 'Kalıcılık Test Uçağı',
      type: 'Sabit Kanat',
      weightKg: 3.0,
      wingAreaM2: 0.8,
      wingSpanM: 2.0,
      motorCount: 1,
      motorPowerW: 1200.0,
      propellerDiameterInch: 15.0,
      batteryCapacityMah: 10000.0,
      batteryVoltageV: 22.2,
      batteryType: 'LiPo',
      batteryCellCount: 6,
      cellInternalResistanceMilliOhm: 4.0,
      cruiseSpeedMs: 18.0,
      zeroLiftDragCoefficient: 0.035,
      maxLiftCoefficient: 1.4,
      oswaldEfficiencyFactor: 0.8,
      escEfficiency: 0.95,
      motorEfficiency: 0.85,
      continuousMotorPowerW: 1000.0,
      maximumMotorPowerW: 1400.0,
      massStations: const [],
      meanAerodynamicChordM: 0.4,
      macLeadingEdgeFromDatumM: 0.4,
      neutralPointPercentMac: 40.0,
      minimumCgPercentMac: 20.0,
      maximumCgPercentMac: 35.0,
      maximumOperatingSpeedMs: 25.0,
      positiveLimitLoadFactor: 3.8,
      negativeLimitLoadFactor: -1.5,
    );
  }

  const environment = Environment(
    altitudeM: 100.0,
    temperatureC: 20.0,
    pressureHpa: 1001.0,
    humidityPercent: 45.0,
    windSpeedKmh: 5.0,
    windDirection: 'Sakin',
  );

  test('saved analysis survives closing and reopening the Hive box', () async {
    final aircraft = createAircraft();
    final result = AnalysisService().analyze(aircraft, environment);
    final firstService = AnalysisHistoryService();

    final saved = await firstService.saveAnalysis(
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    expect(firstService.analysisCount, 1);

    await Hive.box<AnalysisHistoryEntity>(HiveBoxes.analysisHistory).close();

    await Hive.openBox<AnalysisHistoryEntity>(HiveBoxes.analysisHistory);

    final reopenedService = AnalysisHistoryService();
    final persisted = reopenedService.getAnalysisById(saved.id);

    expect(reopenedService.analysisCount, 1);
    expect(persisted, isNotNull);
    expect(persisted?.aircraftName, aircraft.name);
    expect(persisted?.aircraftType, aircraft.type);

    final restoredResult = reopenedService.restoreResult(persisted!);

    expect(restoredResult.overallScore, result.overallScore);
    expect(restoredResult.riskScore, result.riskScore);
  });

  test('deletion remains effective after reopening the Hive box', () async {
    final aircraft = createAircraft();
    final result = AnalysisService().analyze(aircraft, environment);
    final firstService = AnalysisHistoryService();

    final saved = await firstService.saveAnalysis(
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    await firstService.deleteAnalysis(saved.id);

    await Hive.box<AnalysisHistoryEntity>(HiveBoxes.analysisHistory).close();

    await Hive.openBox<AnalysisHistoryEntity>(HiveBoxes.analysisHistory);

    final reopenedService = AnalysisHistoryService();

    expect(reopenedService.analysisCount, 0);
    expect(reopenedService.getAnalysisById(saved.id), isNull);
  });
}
