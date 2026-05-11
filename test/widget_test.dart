import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temple_calendar/main.dart';

void main() {
  testWidgets('Temple Calendar smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TempleCalendarApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
