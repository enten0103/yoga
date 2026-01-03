import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

Future<Uint8List> _makeSolidPng({
  required int width,
  required int height,
  required Color color,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = color;
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    paint,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Widget _buildHarness({required Widget child}) {
  return Directionality(textDirection: TextDirection.ltr, child: child);
}

/// A tiny helper to apply **real Flutter constraints**.
///
/// Note: HtmlDiv's width/height are CSS-like styles; they may not translate into
/// tight parent constraints for children in all layout paths.
Widget _constrain({double? width, double? height, required Widget child}) {
  // IMPORTANT: use max constraints (not tight width/height). Tight constraints
  // (min==max) would force the child to that exact size and can mask the
  // intended CSS-like computation (e.g. `width: 50%` under maxWidth=200).
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: width ?? double.infinity,
      maxHeight: height ?? double.infinity,
    ),
    child: child,
  );
}

void main() {
  const Size naturalPx = Size(100, 50);
  const double naturalScale = 1.0;

  testWidgets('fixed width + auto height uses natural ratio (used width)', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.red);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            _constrain(
              width: 80,
              child: HtmlImage(
                key: const ValueKey('img'),
                image: MemoryImage(pngBytes),
                width: const FixedSize(200),
                height: const AutoSize(),
                naturalPixelSize: naturalPx,
                naturalPixelScale: naturalScale,
                placeholderSize: const Size(1, 1),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));
    expect(s.width, equals(80));
    expect(s.height, equals(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('fixed height + auto width uses natural ratio (used height)', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.green);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            _constrain(
              height: 90,
              child: HtmlImage(
                key: const ValueKey('img'),
                image: MemoryImage(pngBytes),
                width: const AutoSize(),
                height: const FixedSize(200),
                naturalPixelSize: naturalPx,
                naturalPixelScale: naturalScale,
                placeholderSize: const Size(1, 1),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));
    expect(s.height, equals(90));
    expect(s.width, equals(180));
    expect(tester.takeException(), isNull);
  });

  testWidgets('both fixed allows stretching (does not preserve ratio)', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.blue);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            HtmlImage(
              key: const ValueKey('img'),
              image: MemoryImage(pngBytes),
              width: const FixedSize(120),
              height: const FixedSize(90),
              naturalPixelSize: naturalPx,
              naturalPixelScale: naturalScale,
              placeholderSize: const Size(1, 1),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));
    expect(s.width, equals(120));
    expect(s.height, equals(90));
    expect(tester.takeException(), isNull);
  });

  testWidgets('auto/auto uses natural size (subject to constraints)', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.orange);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            _constrain(
              width: 60,
              child: HtmlImage(
                key: const ValueKey('img'),
                image: MemoryImage(pngBytes),
                width: const AutoSize(),
                height: const AutoSize(),
                naturalPixelSize: naturalPx,
                naturalPixelScale: naturalScale,
                placeholderSize: const Size(1, 1),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));

    // natural logical is 100x50; inside width=60, preserve aspect ratio => 60x30
    expect(s.width, equals(60));
    expect(s.height, equals(30));
    expect(tester.takeException(), isNull);
  });

  testWidgets('percent width resolves against bounded maxWidth', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.purple);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            _constrain(
              width: 200,
              child: HtmlImage(
                key: const ValueKey('img'),
                image: MemoryImage(pngBytes),
                width: const PercentSize(50),
                height: const AutoSize(),
                naturalPixelSize: naturalPx,
                naturalPixelScale: naturalScale,
                placeholderSize: const Size(1, 1),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));

    // 50% of maxWidth=200 => usedW=100; height auto by ratio => 50
    expect(s.width, equals(100));
    expect(s.height, equals(50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('percent height resolves against bounded maxHeight', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.teal);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            _constrain(
              height: 120,
              child: HtmlImage(
                key: const ValueKey('img'),
                image: MemoryImage(pngBytes),
                width: const AutoSize(),
                height: const PercentSize(50),
                naturalPixelSize: naturalPx,
                naturalPixelScale: naturalScale,
                placeholderSize: const Size(1, 1),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));

    // 50% of maxHeight=120 => usedH=60; width auto by ratio => 120
    expect(s.height, equals(60));
    expect(s.width, equals(120));
    expect(tester.takeException(), isNull);
  });

  testWidgets('percent width cannot resolve under unbounded maxWidth', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.indigo);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            // In a Row, children get unbounded constraints on the main axis
            // (width), which makes PercentSize() unresolvable.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HtmlImage(
                  key: const ValueKey('img'),
                  image: MemoryImage(pngBytes),
                  width: const PercentSize(50),
                  height: const AutoSize(),
                  naturalPixelSize: naturalPx,
                  naturalPixelScale: naturalScale,
                  placeholderSize: const Size(1, 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));

    // With unbounded width, percent cannot resolve; fall back to auto sizing.
    expect(s.width, equals(100));
    expect(s.height, equals(50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('unsupported HtmlSize (MaxContent) behaves like auto', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.lime);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            _constrain(
              width: 60,
              child: HtmlImage(
                key: const ValueKey('img'),
                image: MemoryImage(pngBytes),
                width: const MaxContent(),
                height: const AutoSize(),
                naturalPixelSize: naturalPx,
                naturalPixelScale: naturalScale,
                placeholderSize: const Size(1, 1),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));
    expect(s.width, equals(60));
    expect(s.height, equals(30));
    expect(tester.takeException(), isNull);
  });

  testWidgets('both percent resolves both axes and allows stretching', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.brown);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            _constrain(
              width: 200,
              height: 100,
              child: HtmlImage(
                key: const ValueKey('img'),
                image: MemoryImage(pngBytes),
                width: const PercentSize(50),
                height: const PercentSize(50),
                naturalPixelSize: naturalPx,
                naturalPixelScale: naturalScale,
                placeholderSize: const Size(1, 1),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));
    expect(s.width, equals(100));
    expect(s.height, equals(50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('negative fixed sizes clamp to >= 0', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.black);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            HtmlImage(
              key: const ValueKey('img'),
              image: MemoryImage(pngBytes),
              width: const FixedSize(-10),
              height: const FixedSize(-20),
              naturalPixelSize: naturalPx,
              naturalPixelScale: naturalScale,
              placeholderSize: const Size(1, 1),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));
    expect(s.width, equals(0));
    expect(s.height, equals(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('naturalPixelScale affects natural logical size', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.cyan);
    });

    await tester.pumpWidget(
      _buildHarness(
        child: HtmlDiv(
          children: [
            HtmlImage(
              key: const ValueKey('img'),
              image: MemoryImage(pngBytes),
              width: const AutoSize(),
              height: const AutoSize(),
              naturalPixelSize: const Size(200, 100),
              naturalPixelScale: 2.0,
              placeholderSize: const Size(1, 1),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final Size s = tester.getSize(find.byKey(const ValueKey('img')));

    // logical size = px / scale => 100x50
    expect(s.width, equals(100));
    expect(s.height, equals(50));
    expect(tester.takeException(), isNull);
  });
}
