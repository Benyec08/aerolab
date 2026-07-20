import 'package:aerolab/app.dart';
import 'package:aerolab/features/analysis/analysis_result_page.dart';
import 'package:aerolab/features/analysis/models/aircraft.dart';
import 'package:aerolab/features/analysis/models/aircraft_mass_station.dart';
import 'package:aerolab/features/analysis/models/environment.dart';
import 'package:aerolab/features/analysis/new_analysis_page.dart';
import 'package:aerolab/features/analysis/services/analysis_service.dart';
import 'package:aerolab/features/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setTestWindow(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;

    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    required Widget page,
    required Size size,
  }) async {
    await setTestWindow(tester, size);

    await tester.pumpWidget(
      MaterialApp(debugShowCheckedModeBanner: false, home: page),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
  }

  void expectNoFlutterException(WidgetTester tester) {
    expect(tester.takeException(), isNull);
  }

  Future<void> scrollPageToBottom(WidgetTester tester) async {
    final scrollableFinder = find.byType(Scrollable);

    if (scrollableFinder.evaluate().isEmpty) {
      return;
    }

    final scrollableState = tester.state<ScrollableState>(
      scrollableFinder.first,
    );

    final position = scrollableState.position;

    if (position.hasContentDimensions && position.maxScrollExtent > 0) {
      position.jumpTo(position.maxScrollExtent);
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(
      tester.takeException(),
      isNull,
      reason: 'Sayfanın sonuna giderken Flutter UI hatası oluştu.',
    );
  }

  Aircraft createFixedWingAircraft() {
    return Aircraft(
      name: 'UI Fixed Wing',
      type: 'Sabit Kanat',
      weightKg: 2.4,
      wingAreaM2: 0.60,
      wingSpanM: 2.0,
      motorCount: 1,
      motorPowerW: 900,
      propellerDiameterInch: 12,
      batteryCapacityMah: 10000,
      batteryVoltageV: 22.2,
      batteryType: 'LiPo',
      batteryCellCount: 6,
      cruiseSpeedMs: 18,
      zeroLiftDragCoefficient: 0.03,
      maxLiftCoefficient: 1.4,
      oswaldEfficiencyFactor: 0.80,
      escEfficiency: 0.95,
      motorEfficiency: 0.85,
      continuousMotorPowerW: 800,
      maximumMotorPowerW: 1000,
      massStations: [
        AircraftMassStation(
          name: 'Motor Sistemi',
          massKg: 0.5,
          armFromDatumM: 0.20,
        ),
        AircraftMassStation(name: 'Batarya', massKg: 0.7, armFromDatumM: 0.45),
        AircraftMassStation(name: 'Gövde', massKg: 1.0, armFromDatumM: 0.50),
        AircraftMassStation(
          name: 'Faydalı Yük',
          massKg: 0.2,
          armFromDatumM: 0.55,
        ),
      ],
      meanAerodynamicChordM: 0.30,
      macLeadingEdgeFromDatumM: 0.40,
      neutralPointPercentMac: 40,
      minimumCgPercentMac: 20,
      maximumCgPercentMac: 35,
      maximumOperatingSpeedMs: 25,
      positiveLimitLoadFactor: 3.8,
      negativeLimitLoadFactor: -1.5,
    );
  }

  Aircraft createDroneAircraft() {
    return Aircraft(
      name: 'UI Drone',
      type: 'Drone',
      weightKg: 2.4,
      wingAreaM2: 0,
      wingSpanM: 0,
      motorCount: 4,
      motorPowerW: 3400,
      propellerDiameterInch: 10,
      batteryCapacityMah: 10000,
      batteryVoltageV: 14.8,
      batteryType: 'LiPo',
      batteryCellCount: 4,
      cruiseSpeedMs: 15,
      escEfficiency: 0.95,
      motorEfficiency: 0.85,
      continuousMotorPowerW: 3200,
      maximumMotorPowerW: 3800,
    );
  }

  Environment createEnvironment() {
    return const Environment(
      altitudeM: 50,
      temperatureC: 25,
      pressureHpa: 1007.3,
      humidityPercent: 40,
      windSpeedKmh: 12,
      windDirection: 'Karşıdan',
    );
  }

  group('Dashboard responsive UI', () {
    testWidgets('renders without overflow at 1280x800', (tester) async {
      await pumpPage(
        tester,
        page: const DashboardPage(),
        size: const Size(1280, 800),
      );

      expect(find.text('AeroLab'), findsOneWidget);
      expect(find.text('Yeni Analiz'), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets('renders without overflow at 900x700', (tester) async {
      await pumpPage(
        tester,
        page: const DashboardPage(),
        size: const Size(900, 700),
      );

      expect(find.text('Araç Kütüphanesi'), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets('renders without overflow at 600x700', (tester) async {
      await pumpPage(
        tester,
        page: const DashboardPage(),
        size: const Size(600, 700),
      );

      expect(find.text('AeroLab'), findsOneWidget);
      expectNoFlutterException(tester);
    });
  });

  group('Dashboard navigation flow', () {
    testWidgets('opens New Analysis from dashboard', (tester) async {
      await setTestWindow(tester, const Size(1280, 800));
      await tester.pumpWidget(const AeroLabApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yeni Analiz'));
      await tester.pumpAndSettle();

      expect(find.byType(NewAnalysisPage), findsOneWidget);
      expect(find.text('Yeni Uçuş Analizi'), findsOneWidget);
      expectNoFlutterException(tester);
    });
  });

  group('New Analysis responsive UI and flow', () {
    testWidgets('renders and scrolls at normal desktop size', (tester) async {
      await pumpPage(
        tester,
        page: const NewAnalysisPage(),
        size: const Size(1000, 800),
      );

      expect(find.text('Yeni Uçuş Analizi'), findsOneWidget);
      expectNoFlutterException(tester);

      await scrollPageToBottom(tester);

      expect(find.text('Analizi Başlat'), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets('renders and scrolls at narrow desktop size', (tester) async {
      await pumpPage(
        tester,
        page: const NewAnalysisPage(),
        size: const Size(600, 700),
      );

      expect(find.text('Yeni Uçuş Analizi'), findsOneWidget);
      expectNoFlutterException(tester);

      await scrollPageToBottom(tester);

      expect(find.text('Analizi Başlat'), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets('valid default Drone form opens result page', (tester) async {
      await pumpPage(
        tester,
        page: const NewAnalysisPage(),
        size: const Size(1000, 800),
      );

      final analyzeButton = find.text('Analizi Başlat');

      await tester.scrollUntilVisible(
        analyzeButton,
        600,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(analyzeButton);
      await tester.pumpAndSettle();

      expect(find.byType(AnalysisResultPage), findsOneWidget);
      expect(find.text('Uçuş Analiz Raporu'), findsOneWidget);
      expectNoFlutterException(tester);
    });
  });

  group('Analysis Result responsive UI', () {
    testWidgets('fixed-wing result renders and scrolls at 1100x800', (
      tester,
    ) async {
      final result = AnalysisService().analyze(
        createFixedWingAircraft(),
        createEnvironment(),
      );

      await pumpPage(
        tester,
        page: AnalysisResultPage(result: result),
        size: const Size(1100, 800),
      );

      expect(find.text('Uçuş Analiz Raporu'), findsOneWidget);
      expect(find.text('Aerodynamic Performance'), findsOneWidget);
      expectNoFlutterException(tester);

      await scrollPageToBottom(tester);
      expectNoFlutterException(tester);
    });

    testWidgets('fixed-wing result renders and scrolls at 600x700', (
      tester,
    ) async {
      final result = AnalysisService().analyze(
        createFixedWingAircraft(),
        createEnvironment(),
      );

      await pumpPage(
        tester,
        page: AnalysisResultPage(result: result),
        size: const Size(600, 700),
      );

      expect(find.text('Uçuş Analiz Raporu'), findsOneWidget);
      expectNoFlutterException(tester);

      await scrollPageToBottom(tester);
      expectNoFlutterException(tester);
    });

    testWidgets('Drone result shows non-applicable fixed-wing metrics safely', (
      tester,
    ) async {
      final result = AnalysisService().analyze(
        createDroneAircraft(),
        createEnvironment(),
      );

      await pumpPage(
        tester,
        page: AnalysisResultPage(result: result),
        size: const Size(600, 700),
      );

      expect(find.text('Uçuş Analiz Raporu'), findsOneWidget);
      expect(find.text('Fixed-Wing Lift Model'), findsOneWidget);
      expect(find.text('Uygulanamaz'), findsWidgets);
      expectNoFlutterException(tester);

      await scrollPageToBottom(tester);
      expectNoFlutterException(tester);
    });
  });
}
