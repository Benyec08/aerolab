import 'package:aerolab/data/entities/analysis_history_entity.dart';
import 'package:aerolab/data/services/analysis_history_service.dart';
import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/analysis_result.dart';
import 'package:aerolab/features/analysis/models/environment.dart';
import 'package:aerolab/features/analysis/services/analysis_service.dart';
import 'package:aerolab/features/reports/reports_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReportHistoryService extends AnalysisHistoryService {
  final List<AnalysisHistoryEntity> records;
  final Aircraft aircraft;
  final Environment environment;
  final AnalysisResult result;

  _FakeReportHistoryService({
    required List<AnalysisHistoryEntity> records,
    required this.aircraft,
    required this.environment,
    required this.result,
  }) : records = List<AnalysisHistoryEntity>.from(records);

  @override
  List<AnalysisHistoryEntity> getAllAnalyses() {
    final sorted = List<AnalysisHistoryEntity>.from(records)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sorted;
  }

  @override
  Aircraft restoreAircraft(AnalysisHistoryEntity history) {
    return aircraft;
  }

  @override
  Environment restoreEnvironment(AnalysisHistoryEntity history) {
    return environment;
  }

  @override
  AnalysisResult restoreResult(AnalysisHistoryEntity history) {
    return result;
  }
}

void main() {
  final aircraft = Aircraft(
    name: 'Rapor Test Uçağı',
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

  Future<void> pumpReportsPage(
    WidgetTester tester,
    _FakeReportHistoryService service,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: ReportsPage(historyService: service)),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('shows empty state when no reports are available', (
    tester,
  ) async {
    final service = _FakeReportHistoryService(
      records: const [],
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    await pumpReportsPage(tester, service);

    expect(find.text('Raporlar'), findsOneWidget);
    expect(
      find.text('Henüz rapor oluşturulabilecek analiz yok'),
      findsOneWidget,
    );
  });

  testWidgets('lists available reports from newest to oldest', (tester) async {
    final service = _FakeReportHistoryService(
      records: [
        createRecord(
          id: 'old',
          aircraftName: 'Eski Rapor',
          createdAt: DateTime(2026, 7, 20, 10),
        ),
        createRecord(
          id: 'new',
          aircraftName: 'Yeni Rapor',
          createdAt: DateTime(2026, 7, 21, 18, 30),
        ),
      ],
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    await pumpReportsPage(tester, service);

    expect(find.text('2 kullanılabilir rapor'), findsOneWidget);
    expect(find.text('Yeni Rapor'), findsOneWidget);
    expect(find.text('Eski Rapor'), findsOneWidget);

    final newPosition = tester.getTopLeft(find.text('Yeni Rapor')).dy;
    final oldPosition = tester.getTopLeft(find.text('Eski Rapor')).dy;

    expect(newPosition, lessThan(oldPosition));
  });

  testWidgets('opens engineering report from a saved analysis', (tester) async {
    final service = _FakeReportHistoryService(
      records: [
        createRecord(
          id: 'report-1',
          aircraftName: 'Açılacak Rapor',
          createdAt: DateTime(2026, 7, 21, 18, 30),
        ),
      ],
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    await pumpReportsPage(tester, service);

    await tester.tap(find.text('Açılacak Rapor'));
    await tester.pumpAndSettle();

    expect(find.byType(EngineeringReportPage), findsOneWidget);
    expect(find.text('Mühendislik Raporu'), findsOneWidget);
    expect(find.text('AeroLab Mühendislik Analiz Raporu'), findsOneWidget);
    expect(find.text('Rapor Test Uçağı'), findsWidgets);
  });

  testWidgets('shows all primary engineering report sections', (tester) async {
    final service = _FakeReportHistoryService(
      records: [
        createRecord(
          id: 'report-1',
          aircraftName: 'Bölüm Test Raporu',
          createdAt: DateTime(2026, 7, 21, 18, 30),
        ),
      ],
      aircraft: aircraft,
      environment: environment,
      result: result,
    );

    await pumpReportsPage(tester, service);

    await tester.tap(find.text('Bölüm Test Raporu'));
    await tester.pumpAndSettle();

    expect(find.text('Araç Bilgileri'), findsOneWidget);
    expect(find.text('Çevre Koşulları'), findsOneWidget);
    expect(find.text('Temel Aerodinamik'), findsOneWidget);
    expect(find.text('Güç ve İtki'), findsOneWidget);
    expect(find.text('Enerji ve Batarya'), findsOneWidget);
    expect(find.text('Uçuş Performansı'), findsOneWidget);
    expect(find.text('Skorlar ve Risk'), findsOneWidget);
    expect(
      find.text('Mühendislik Değerlendirmesi ve Öneriler'),
      findsOneWidget,
    );
  });
}
