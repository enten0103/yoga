import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter_yoga/html_div.dart';
import 'package:flutter_yoga_example/pages/inline_text_align_page.dart';

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

  Future<List<int>> collectTextInkRowsForBoundary(
    WidgetTester tester, {
    required Key boundaryKey,
  }) async {
    final RenderRepaintBoundary boundary = tester.renderObject(
      find.byKey(boundaryKey),
    );
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    expect(bytes, isNotNull);

    final int w = image.width;
    final int h = image.height;
    final ByteData data = bytes!;

    // Sample background away from borders.
    final int bgX = w > 4 ? 2 : 0;
    final int bgY = h > 4 ? 2 : 0;
    final int bgIdx = (bgY * w + bgX) * 4;
    final int bgR = data.getUint8(bgIdx);
    final int bgG = data.getUint8(bgIdx + 1);
    final int bgB = data.getUint8(bgIdx + 2);
    final int bgA = data.getUint8(bgIdx + 3);

    bool isInk(int r, int g, int b, int a) {
      if (a == 0) return false;
      final int dr = (r - bgR).abs();
      final int dg = (g - bgG).abs();
      final int db = (b - bgB).abs();
      final int da = (a - bgA).abs();
      return (dr + dg + db + da) > 80;
    }

    // Stay away from edges so borders/anti-aliasing don't pollute the signal.
    final int xStart = (w * 0.10).clamp(0, w - 1).toInt();
    final int xEnd = (w * 0.90).clamp(0, w - 1).toInt();
    final int yStart = (h * 0.05).clamp(0, h - 1).toInt();
    final int yEnd = (h * 0.95).clamp(0, h - 1).toInt();

    const int minInkPerRow = 10;
    final List<int> inkRows = <int>[];
    for (int y = yStart; y <= yEnd; y++) {
      int inkCount = 0;
      final int rowPixels = (xEnd - xStart + 1).clamp(1, w);
      for (int x = xStart; x <= xEnd; x++) {
        final int idx = (y * w + x) * 4;
        final int r = data.getUint8(idx);
        final int g = data.getUint8(idx + 1);
        final int b = data.getUint8(idx + 2);
        final int a = data.getUint8(idx + 3);
        if (isInk(r, g, b, a)) inkCount++;
      }

      // Ignore near-full-width strokes (borders).
      // Ignore very sparse rows which are usually anti-aliasing noise.
      if (inkCount >= minInkPerRow && inkCount < (rowPixels * 0.80)) {
        inkRows.add(y);
      }
    }

    return inkRows;
  }

  int countRowClusters(List<int> inkRows, {int gapThreshold = 8}) {
    if (inkRows.isEmpty) return 0;
    int clusters = 1;
    for (int i = 1; i < inkRows.length; i++) {
      final int gap = inkRows[i] - inkRows[i - 1];
      if (gap > gapThreshold) clusters++;
    }
    return clusters;
  }

  Future<int> countInkRowClustersForBoundary(
    WidgetTester tester, {
    required Key boundaryKey,
  }) async {
    final List<int> inkRows = await collectTextInkRowsForBoundary(
      tester,
      boundaryKey: boundaryKey,
    );
    if (inkRows.isEmpty) return 0;
    return countRowClusters(inkRows);
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

  testWidgets(
    'lineHeight on nested inline HtmlDiv does not force wrapping (start/center/end)',
    (WidgetTester tester) async {
      Future<void> pumpLineHeightCase(HtmlTextAlign align) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.noScaling),
              child: Center(
                child: HtmlDiv(
                  width: const FixedSize(320),
                  height: const AutoSize(),
                  textAlign: align,
                  border: HtmlBorder.all(width: const FixedBorderWidth(0)),
                  children: [
                    HtmlDiv(
                      lineHeight: HtmlLength.px(14),
                      display: HtmlDisplay.inline,
                      children: const [
                        HtmlText(
                          '轻之国度录入组',
                          key: ValueKey('lh.left'),
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                    const HtmlText(
                      'x',
                      key: ValueKey('lh.x'),
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                    HtmlDiv(
                      lineHeight: HtmlLength.px(22),
                      display: HtmlDisplay.inline,
                      children: const [
                        HtmlText(
                          '虚空文学旅团',
                          key: ValueKey('lh.right'),
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<void> assertSingleLine() async {
        final RenderHtmlText left = tester.renderObject(
          find.byKey(const ValueKey('lh.left')),
        );
        final RenderHtmlText right = tester.renderObject(
          find.byKey(const ValueKey('lh.right')),
        );

        expect(left.debugLineCount, 1);
        expect(right.debugLineCount, 1);
        expect(tester.takeException(), isNull);
      }

      await pumpLineHeightCase(HtmlTextAlign.start);
      await assertSingleLine();

      await pumpLineHeightCase(HtmlTextAlign.center);
      await assertSingleLine();

      await pumpLineHeightCase(HtmlTextAlign.end);
      await assertSingleLine();
    },
  );

  testWidgets(
    'InlineTextAlignPage: mixedSingleLine stays single-line when lineHeight is set',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: InlineTextAlignPage()));
      await tester.pumpAndSettle();

      Future<void> assertOneLineFor(String alignKey) async {
        final Key rbKey = ValueKey('mixedSingleLine.$alignKey.rb');
        final Finder frameFinder = find.byKey(
          ValueKey('mixedSingleLine.$alignKey.frame'),
        );
        final Finder leftFinder = find.byKey(
          ValueKey('mixedSingleLine.$alignKey.left'),
        );
        final Finder rightFinder = find.byKey(
          ValueKey('mixedSingleLine.$alignKey.right'),
        );

        final HtmlDiv frameWidget = tester.widget(frameFinder);
        expect(frameWidget.display, HtmlDisplay.inline);

        await tester.ensureVisible(leftFinder);
        await tester.ensureVisible(rightFinder);

        final RenderHtmlText left = tester.renderObject(leftFinder);
        final RenderHtmlText right = tester.renderObject(rightFinder);

        final HtmlText leftWidget = tester.widget(leftFinder);
        final HtmlText rightWidget = tester.widget(rightFinder);
        expect(leftWidget.data, '轻之国度录入组');
        expect(rightWidget.data, '虚空文学旅团');

        expect(left.debugLineCount, 1);
        expect(right.debugLineCount, 1);

        // Pixel check: ensure there isn't a second row cluster of ink.
        final int clusters = await countInkRowClustersForBoundary(
          tester,
          boundaryKey: rbKey,
        );
        expect(clusters, 1);

        // Harder pixel check: single-line text should keep its ink within a
        // relatively tight vertical span (two lines would expand this span).
        final List<int> inkRows = await collectTextInkRowsForBoundary(
          tester,
          boundaryKey: rbKey,
        );
        expect(inkRows, isNotEmpty);
        final int inkSpan = inkRows.last - inkRows.first;
        expect(
          inkSpan,
          lessThan(40),
          reason: 'Expected single-line ink span; got inkSpan=$inkSpan',
        );
      }

      await assertOneLineFor('start');
      await assertOneLineFor('center');
      await assertOneLineFor('end');
      expect(tester.takeException(), isNull);
    },
  );
}
