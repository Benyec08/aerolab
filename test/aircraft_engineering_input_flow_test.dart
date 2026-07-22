import 'package:aerolab/data/entities/aircraft_entity.dart';
import 'package:aerolab/features/hangar/aircraft_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('aircraft form exposes aerodynamic engineering inputs', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AircraftFormDialog())),
    );

    expect(find.text('Aerodinamik Performans'), findsOneWidget);
    expect(find.text('Seyir Hızı'), findsOneWidget);
    expect(
      find.text('Sıfır Kaldırma Sürükleme Katsayısı (Cd0)'),
      findsOneWidget,
    );
    expect(find.text('Maksimum Kaldırma Katsayısı (CLmax)'), findsOneWidget);
    expect(find.text('Oswald Verimlilik Faktörü'), findsOneWidget);
  });

  testWidgets('edit form restores persisted aerodynamic values', (
    tester,
  ) async {
    final aircraft = AircraftEntity.create(
      name: 'Engineering Input Test',
      type: 'Sabit Kanat',
      weightKg: 3,
      wingAreaM2: 0.8,
      wingSpanM: 2,
      motorCount: 1,
      motorPowerW: 1200,
      propellerDiameterInch: 15,
      batteryCapacityMah: 10000,
      batteryVoltageV: 22.2,
      batteryType: 'LiPo',
      batteryCellCount: 6,
      batteryDescription: '6S LiPo',
      cruiseSpeedMs: 18,
      zeroLiftDragCoefficient: 0.035,
      maxLiftCoefficient: 1.4,
      oswaldEfficiencyFactor: 0.8,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AircraftFormDialog(aircraft: aircraft.toMap())),
      ),
    );

    Finder fieldWithValue(String value) {
      return find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.controller?.text == value,
      );
    }

    expect(fieldWithValue('18.0'), findsOneWidget);
    expect(fieldWithValue('0.035'), findsOneWidget);
    expect(fieldWithValue('1.4'), findsOneWidget);
    expect(fieldWithValue('80'), findsOneWidget);
  });
}
