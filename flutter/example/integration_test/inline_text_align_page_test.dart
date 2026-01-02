import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter_yoga/html_div.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpCase(
    WidgetTester tester, {
    required HtmlTextAlign align,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HtmlDiv(
              key: const ValueKey('root'),
              width: const FixedSize(320),
              height: const AutoSize(),
              textAlign: align,
              border: HtmlBorder.all(width: const FixedBorderWidth(1)),
              children: [
                const HtmlText(
                  'Hello ',
                  key: ValueKey('t1'),
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                HtmlImage(
                  key: const ValueKey('img'),
                  image: const AssetImage('assets/test1.png'),
                  width: const FixedSize(60),
                  height: const FixedSize(20),
                  // Keep placeholder non-zero so the layout path is stable.
                  placeholderSize: const Size(1, 1),
                  debugLabel: 'img',
                ),
                const HtmlText(
                  ' world',
                  key: ValueKey('t2'),
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpTextOnlyCase(
    WidgetTester tester, {
    required HtmlTextAlign align,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: const ValueKey('rb'),
              child: HtmlDiv(
                key: const ValueKey('root'),
                width: const FixedSize(320),
                height: const AutoSize(),
                textAlign: align,
                // Use a solid background and no border so pixel scans are stable.
                background: const HtmlBackground(color: Colors.white),
                children: const [
                  HtmlText(
                    'Hello ',
                    key: ValueKey('t1'),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black,
                    ),
                  ),
                  HtmlText(
                    ' world',
                    key: ValueKey('t2'),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<int> scanFirstDarkPixelX(WidgetTester tester) async {
    final RenderRepaintBoundary boundary = tester.renderObject(
      find.byKey(const ValueKey('rb')),
    );
    // Ensure we are scanning the HtmlDiv itself (should be fixed width).
    expect(boundary.size.width, greaterThan(300));
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    expect(bytes, isNotNull);

    final int w = image.width;
    final int h = image.height;
    final ByteData data = bytes!;

    // Sample background from top-left.
    int bgR = data.getUint8(0);
    int bgG = data.getUint8(1);
    int bgB = data.getUint8(2);
    int bgA = data.getUint8(3);

    // Scan a vertical band through the first line area to be robust against
    // platform font metrics.
    final int yStart = (h * 0.20).clamp(0, h - 1).toInt();
    final int yEnd = (h * 0.70).clamp(0, h - 1).toInt();
    bool isInk(int r, int g, int b, int a) {
      if (a == 0) return false;
      // Ignore tiny background drift; require a notable delta from bg.
      final int dr = (r - bgR).abs();
      final int dg = (g - bgG).abs();
      final int db = (b - bgB).abs();
      final int da = (a - bgA).abs();
      return (dr + dg + db + da) > 80;
    }

    for (int y = yStart; y <= yEnd; y++) {
      for (int x = 0; x < w; x++) {
        final int idx = (y * w + x) * 4;
        final int r = data.getUint8(idx);
        final int g = data.getUint8(idx + 1);
        final int b = data.getUint8(idx + 2);
        final int a = data.getUint8(idx + 3);
        if (isInk(r, g, b, a)) {
          return x;
        }
      }
    }
    return -1;
  }

  testWidgets('inline textAlign.center keeps image between spans', (
    WidgetTester tester,
  ) async {
    await pumpCase(tester, align: HtmlTextAlign.center);

    final Offset rootTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('root')),
    );
    final Offset t1TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t1')),
    );
    final Offset imgTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('img')),
    );
    final Offset t2TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t2')),
    );

    // Center should shift the run away from x=0.
    expect(t1TopLeft.dx, greaterThan(rootTopLeft.dx));
    // Order must be preserved.
    expect(t1TopLeft.dx, lessThan(imgTopLeft.dx));
    expect(imgTopLeft.dx, lessThan(t2TopLeft.dx));
  });

  testWidgets('inline textAlign.end keeps image between spans', (
    WidgetTester tester,
  ) async {
    await pumpCase(tester, align: HtmlTextAlign.end);

    final Offset rootTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('root')),
    );
    final Offset t1TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t1')),
    );
    final Offset imgTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('img')),
    );
    final Offset t2TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t2')),
    );

    // End should shift the run away from x=0.
    expect(t1TopLeft.dx, greaterThan(rootTopLeft.dx));
    // Order must be preserved.
    expect(t1TopLeft.dx, lessThan(imgTopLeft.dx));
    expect(imgTopLeft.dx, lessThan(t2TopLeft.dx));
  });

  testWidgets('inline textAlign.center works without image', (
    WidgetTester tester,
  ) async {
    await pumpTextOnlyCase(tester, align: HtmlTextAlign.center);

    final Offset rootTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('root')),
    );
    final Offset t1TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t1')),
    );
    final Offset t2TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t2')),
    );

    expect(t1TopLeft.dx, greaterThan(rootTopLeft.dx));
    expect(t1TopLeft.dx, lessThan(t2TopLeft.dx));
  });

  testWidgets('inline textAlign.end works without image', (
    WidgetTester tester,
  ) async {
    await pumpTextOnlyCase(tester, align: HtmlTextAlign.end);

    final Offset rootTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('root')),
    );
    final Offset t1TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t1')),
    );
    final Offset t2TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t2')),
    );

    expect(t1TopLeft.dx, greaterThan(rootTopLeft.dx));
    expect(t1TopLeft.dx, lessThan(t2TopLeft.dx));
  });

  testWidgets(
    'inline textAlign.center actually paints centered (pixel check)',
    (WidgetTester tester) async {
      await pumpTextOnlyCase(tester, align: HtmlTextAlign.center);

      final int x = await scanFirstDarkPixelX(tester);
      expect(x, greaterThanOrEqualTo(0));

      // Expect the first ink pixel to be away from the left edge when centered.
      // Use a generous threshold to tolerate font rasterization.
      expect(x, greaterThan(20));
    },
  );

  testWidgets(
    'inline textAlign.end actually paints to the right (pixel check)',
    (WidgetTester tester) async {
      await pumpTextOnlyCase(tester, align: HtmlTextAlign.end);

      final int x = await scanFirstDarkPixelX(tester);
      expect(x, greaterThanOrEqualTo(0));

      // Expect the first ink pixel to be further right than the centered case.
      expect(x, greaterThan(40));
    },
  );
}
