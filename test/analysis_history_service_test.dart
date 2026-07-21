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
  late AnalysisHistoryService historyService;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'aerolab_analysis_history_service_test_',
    );

    Hive.init(tempDirectory.path);

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AnalysisHistoryEntityAdapter());
    }

    await Hive.openBox<AnalysisHistoryEntity>(HiveBoxes.analysisHistory);

    historyService = AnalysisHistoryService();
  });

  tearDown(() async {
    await Hive.close();

    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  Aircraft createAircraft() {
    return Aircraft(
      name: 'Servis Test Uçağı',
      type: 'Sabit Kanat',
      weightKg: 4.2,
      wingAreaM2: 1.1,
      wingSpanM: 2.2,
      motorCount: 1,
      motorPowerW: 1500.0,
      propellerDiameterInch: 15.0,
      batteryCapacityMah: 8000.0,
      batteryVoltageV: 22.2,
      batteryType: 'LiPo',
      batteryCellCount: 6,
      cellInternalResistanceMilliOhm: 4.0,
      cruiseSpeedMs: 19.0,
      zeroLiftDragCoefficient: 0.034,
      maxLiftCoefficient: 1.45,
      oswaldEfficiencyFactor: 0.8,
      escEfficiency: 0.95,
      motorEfficiency: 0.88,
      continuousMotorPowerW: 1400.0,
      maximumMotorPowerW: 1800.0,
      massStations: [],
      meanAerodynamicChordM: 0.5,
      macLeadingEdgeFromDatumM: 0.6,
      neutralPointPercentMac: 40.0,
      minimumCgPercentMac: 20.0,
      maximumCgPercentMac: 35.0,
      maximumOperatingSpeedMs: 34.0,
      positiveLimitLoadFactor: 3.8,
      negativeLimitLoadFactor: -1.5,
    );
  }

  const environment = Environment(
    altitudeM: 500.0,
    temperatureC: 20.0,
    pressureHpa: 954.0,
    humidityPercent: 45.0,
    windSpeedKmh: 8.0,
    windDirection: 'Karşıdan',
  );

  test('saves and restores a complete analysis', () async {
    final aircraft = createAircraft();
    final result = AnalysisService().analyze(aircraft, environment);

    final saved = await historyService.saveAnalysis(
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    expect(historyService.analysisCount, 1);

    final restoredAircraft = historyService.restoreAircraft(saved);
    final restoredEnvironment = historyService.restoreEnvironment(saved);
    final restoredResult = historyService.restoreResult(saved);

    expect(restoredAircraft.name, aircraft.name);
    expect(restoredAircraft.type, aircraft.type);
    expect(restoredEnvironment.altitudeM, environment.altitudeM);
    expect(restoredResult.overallScore, result.overallScore);
    expect(restoredResult.riskScore, result.riskScore);
  });

  test('returns analyses from newest to oldest', () async {
    final aircraft = createAircraft();
    final result = AnalysisService().analyze(aircraft, environment);

    final first = await historyService.saveAnalysis(
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    await Future<void>.delayed(const Duration(milliseconds: 2));

    final second = await historyService.saveAnalysis(
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    final analyses = historyService.getAllAnalyses();

    expect(analyses, hasLength(2));
    expect(analyses.first.id, second.id);
    expect(analyses.last.id, first.id);
  });

  test('deletes one analysis and clears all remaining analyses', () async {
    final aircraft = createAircraft();
    final result = AnalysisService().analyze(aircraft, environment);

    final first = await historyService.saveAnalysis(
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    await historyService.saveAnalysis(
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    await historyService.deleteAnalysis(first.id);

    expect(historyService.analysisCount, 1);
    expect(historyService.getAnalysisById(first.id), isNull);

    await historyService.clearHistory();

    expect(historyService.analysisCount, 0);
    expect(historyService.getAllAnalyses(), isEmpty);
  });
}
