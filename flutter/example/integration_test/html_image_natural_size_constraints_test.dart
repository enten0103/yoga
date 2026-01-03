import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_yoga_example/pages/html_image_natural_size_constraints_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HtmlImage naturalPixelSize stays correct under constraints', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HtmlImageNaturalSizeConstraintsPage()),
    );
    await tester.pumpAndSettle();

    final Size a = tester.getSize(find.byKey(const ValueKey('caseA')));
    // Parent clamps width to 120; keep 16:9 => height = 120 * 2160/3840 = 67.5
    expect(a.width, equals(120));
    expect(a.height, closeTo(67.5, 0.2));

    final Size b = tester.getSize(find.byKey(const ValueKey('caseB')));
    // Parent clamps height to 90; keep 16:9 => width = 90 * 3840/2160 = 160
    expect(b.height, equals(90));
    expect(b.width, closeTo(160.0, 0.5));

    expect(tester.takeException(), isNull);
  });
}
