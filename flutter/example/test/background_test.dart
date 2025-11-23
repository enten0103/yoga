import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga_example/examples/background_page.dart';

void main() {
  testWidgets('BackgroundPage renders repeat examples', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BackgroundPage()));
    await tester.pumpAndSettle();

    // Find the repeat example text
    expect(find.text('Repeat (Default)'), findsOneWidget);

    // We can't easily assert painting output in a widget test without golden tests,
    // but running this will trigger the paint method and our debug prints.
  });
}
