import 'package:aerolab/data/entities/analysis_history_entity.dart';
import 'package:aerolab/data/services/analysis_history_service.dart';
import 'package:aerolab/features/analysis/analysis_result_page.dart';
import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/analysis_result.dart';
import 'package:aerolab/features/analysis/models/environment.dart';
import 'package:aerolab/features/analysis/services/analysis_service.dart';
import 'package:aerolab/features/history/analysis_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAnalysisHistoryService extends AnalysisHistoryService {
  final List<AnalysisHistoryEntity> records;
  final AnalysisResult result;

  _FakeAnalysisHistoryService({
    required List<AnalysisHistoryEntity> records,
    required this.result,
  }) : records = List<AnalysisHistoryEntity>.from(records);

  @override
  List<AnalysisHistoryEntity> getAllAnalyses() {
    final sorted = List<AnalysisHistoryEntity>.from(records)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sorted;
  }

  @override
  AnalysisResult restoreResult(AnalysisHistoryEntity history) {
    return result;
  }

  @override
  Future<void> deleteAnalysis(String id) async {
    records.removeWhere((record) => record.id == id);
  }

  @override
  Future<void> clearHistory() async {
    records.clear();
  }
}

void main() {
  final aircraft = Aircraft(
    name: 'Geçmiş Test Uçağı',
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
    massStations: [],
    meanAerodynamicChordM: 0.4,
    macLeadingEdgeFromDatumM: 0.4,
    neutralPointPercentMac: 40.0,
    minimumCgPercentMac: 20.0,
    maximumCgPercentMac: 35.0,
    maximumOperatingSpeedMs: 25.0,
    positiveLimitLoadFactor: 3.8,
    negativeLimitLoadFactor: -1.5,
  );

  const environment = Environment(
    altitudeM: 100.0,
    temperatureC: 20.0,
    pressureHpa: 1001.0,
    humidityPercent: 45.0,
    windSpeedKmh: 5.0,
    windDirection: 'Sakin',
  );

  late AnalysisResult result;

  setUpAll(() {
    result = AnalysisService().analyze(aircraft, environment);
  });

  AnalysisHistoryEntity createRecord({
    required String id,
    required String aircraftName,
    required DateTime createdAt,
  }) {
    return AnalysisHistoryEntity(
      id: id,
      createdAt: createdAt,
      aircraftName: aircraftName,
      aircraftType: 'Sabit Kanat',
      aircraftDataJson: '{}',
      environmentDataJson: '{}',
      resultDataJson: '{}',
    );
  }

  Future<void> pumpHistoryPage(
    WidgetTester tester,
    _FakeAnalysisHistoryService service,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: AnalysisHistoryPage(historyService: service)),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('shows an empty state when there are no saved analyses', (
    tester,
  ) async {
    final service = _FakeAnalysisHistoryService(
      records: const [],
      result: result,
    );

    await pumpHistoryPage(tester, service);

    expect(find.text('Analiz Geçmişi'), findsOneWidget);
    expect(find.text('Henüz analiz kaydı yok'), findsOneWidget);
    expect(
      find.text(
        'Tamamladığınız analizler otomatik olarak burada listelenecek.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('lists saved analyses from newest to oldest', (tester) async {
    final service = _FakeAnalysisHistoryService(
      records: [
        createRecord(
          id: 'old',
          aircraftName: 'Eski Analiz',
          createdAt: DateTime(2026, 7, 20, 10),
        ),
        createRecord(
          id: 'new',
          aircraftName: 'Yeni Analiz',
          createdAt: DateTime(2026, 7, 21, 18, 30),
        ),
      ],
      result: result,
    );

    await pumpHistoryPage(tester, service);

    expect(find.text('2 kayıtlı analiz'), findsOneWidget);
    expect(find.text('Yeni Analiz'), findsOneWidget);
    expect(find.text('Eski Analiz'), findsOneWidget);

    final newPosition = tester.getTopLeft(find.text('Yeni Analiz')).dy;
    final oldPosition = tester.getTopLeft(find.text('Eski Analiz')).dy;

    expect(newPosition, lessThan(oldPosition));
  });

  testWidgets('opens the saved analysis result page', (tester) async {
    final service = _FakeAnalysisHistoryService(
      records: [
        createRecord(
          id: 'history-1',
          aircraftName: 'Açılacak Analiz',
          createdAt: DateTime(2026, 7, 21, 18, 30),
        ),
      ],
      result: result,
    );

    await pumpHistoryPage(tester, service);

    await tester.tap(find.text('Açılacak Analiz'));
    await tester.pumpAndSettle();

    expect(find.byType(AnalysisResultPage), findsOneWidget);
    expect(find.text('Analiz Sonucu'), findsOneWidget);
  });

  testWidgets('deletes one record and clears all remaining records', (
    tester,
  ) async {
    final service = _FakeAnalysisHistoryService(
      records: [
        createRecord(
          id: 'history-1',
          aircraftName: 'Birinci Analiz',
          createdAt: DateTime(2026, 7, 20),
        ),
        createRecord(
          id: 'history-2',
          aircraftName: 'İkinci Analiz',
          createdAt: DateTime(2026, 7, 21),
        ),
      ],
      result: result,
    );

    await pumpHistoryPage(tester, service);

    await tester.tap(find.byTooltip('Analizi sil').first);
    await tester.pumpAndSettle();

    expect(find.text('Analizi sil'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sil'));
    await tester.pumpAndSettle();

    expect(find.text('1 kayıtlı analiz'), findsOneWidget);
    expect(service.records, hasLength(1));

    await tester.tap(find.byTooltip('Tüm geçmişi temizle'));
    await tester.pumpAndSettle();

    expect(find.text('Tüm geçmişi temizle'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Tümünü Sil'));
    await tester.pumpAndSettle();

    expect(find.text('Henüz analiz kaydı yok'), findsOneWidget);
    expect(service.records, isEmpty);
  });
}
