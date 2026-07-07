import 'package:flutter_test/flutter_test.dart';
import 'package:aerolab/app.dart';

void main() {
  testWidgets('AeroLab app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const AeroLabApp());

    expect(find.text('AeroLab'), findsOneWidget);
  });
}