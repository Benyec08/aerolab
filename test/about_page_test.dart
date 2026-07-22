import 'package:aerolab/core/constants/app_info.dart';
import 'package:aerolab/features/about/about_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAboutPage(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));

    await tester.pumpAndSettle();
  }

  testWidgets('shows application and version information', (tester) async {
    await pumpAboutPage(tester);

    expect(find.text('Hakkında'), findsOneWidget);
    expect(find.text(AppInfo.name), findsOneWidget);
    expect(find.text(AppInfo.fullVersion), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(AppInfo.developer),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(AppInfo.developer), findsOneWidget);
  });

  testWidgets('shows primary project information sections', (tester) async {
    await pumpAboutPage(tester);

    expect(find.text('AeroLab Nedir?'), findsOneWidget);
    expect(find.text('Temel Özellikler'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Teknoloji'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Teknoloji'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Geliştirici'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Geliştirici'), findsOneWidget);
  });
}
