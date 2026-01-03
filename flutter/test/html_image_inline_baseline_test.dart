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

void main() {
  testWidgets('inline HtmlImage baseline should not lift above container', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.red);
    });

    const containerKey = ValueKey('container');
    const imgKey = ValueKey('img');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: HtmlDiv(
            key: containerKey,
            children: [
              const HtmlText('Aa', style: TextStyle(fontSize: 14)),
              // Repro: inline wrapper with a very large line-height that wraps
              // an image. If baseline is computed from the wrapper's full box
              // height, the image can be shifted upward and appear above the
              // container.
              HtmlDiv(
                display: HtmlDisplay.inline,
                lineHeight: const HtmlLength.px(100),
                children: [
                  HtmlImage(
                    key: imgKey,
                    image: MemoryImage(pngBytes),
                    width: const FixedSize(20),
                    height: const FixedSize(20),
                    // Natural size is always declared in tests.
                    naturalPixelSize: const Size(20, 20),
                    naturalPixelScale: 1.0,
                    placeholderSize: const Size(1, 1),
                  ),
                ],
              ),
              const HtmlText('gg', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final double containerTop = tester.getTopLeft(find.byKey(containerKey)).dy;
    final double imgTop = tester.getTopLeft(find.byKey(imgKey)).dy;

    // The image should stay within (or at least not above) the container.
    expect(imgTop + 0.01, greaterThanOrEqualTo(containerTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline HtmlImage (auto/auto) stays within container', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.green);
    });

    const containerKey = ValueKey('container');
    const imgKey = ValueKey('img');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: HtmlDiv(
            key: containerKey,
            children: [
              const HtmlText('Aa', style: TextStyle(fontSize: 14)),
              HtmlDiv(
                display: HtmlDisplay.inline,
                lineHeight: const HtmlLength.px(100),
                children: [
                  HtmlImage(
                    key: imgKey,
                    image: MemoryImage(pngBytes),
                    width: const AutoSize(),
                    height: const AutoSize(),
                    naturalPixelSize: const Size(20, 20),
                    naturalPixelScale: 1.0,
                    placeholderSize: const Size(1, 1),
                  ),
                ],
              ),
              const HtmlText('gg', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final double containerTop = tester.getTopLeft(find.byKey(containerKey)).dy;
    final double imgTop = tester.getTopLeft(find.byKey(imgKey)).dy;
    expect(imgTop + 0.01, greaterThanOrEqualTo(containerTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('small lineHeight should not pull tall image above container', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.blue);
    });

    const containerKey = ValueKey('container');
    const imgKey = ValueKey('img');

    const wrapperKey = ValueKey('wrapper');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: HtmlDiv(
            key: containerKey,
            border: HtmlBorder.all(width: const FixedBorderWidth(1)),
            children: [
              const HtmlText('Aa', style: TextStyle(fontSize: 14)),
              HtmlDiv(
                key: wrapperKey,
                display: HtmlDisplay.inline,
                lineHeight: const HtmlLength.px(16),
                children: [
                  HtmlImage(
                    key: imgKey,
                    image: MemoryImage(pngBytes),
                    width: const FixedSize(20),
                    height: const FixedSize(240),
                    naturalPixelSize: const Size(20, 240),
                    naturalPixelScale: 1.0,
                    placeholderSize: const Size(1, 1),
                  ),
                ],
              ),
              const HtmlText('gg', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final double containerTop = tester.getTopLeft(find.byKey(containerKey)).dy;
    final double wrapperTop = tester.getTopLeft(find.byKey(wrapperKey)).dy;
    final double imgTop = tester.getTopLeft(find.byKey(imgKey)).dy;

    // If this fails, it means the inline wrapper itself is placed above the
    // container due to baseline/placeholder layout.
    expect(wrapperTop + 0.01, greaterThanOrEqualTo(containerTop));
    // If this fails (but wrapperTop is OK), the image is being positioned above
    // its own inline wrapper.
    expect(imgTop + 0.01, greaterThanOrEqualTo(containerTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('block HtmlDiv lineHeight should not inflate height', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.purple);
    });

    const wrapperKey = ValueKey('wrapper');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: HtmlDiv(
            children: [
              HtmlDiv(
                key: wrapperKey,
                // Default display is block.
                lineHeight: const HtmlLength.px(16),
                children: [
                  HtmlImage(
                    image: MemoryImage(pngBytes),
                    width: const AutoSize(),
                    height: const FixedSize(240),
                    naturalPixelSize: const Size(20, 240),
                    naturalPixelScale: 1.0,
                    placeholderSize: const Size(1, 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size wrapperSize = tester.getSize(find.byKey(wrapperKey));
    // The block wrapper should size roughly to the image's used height.
    // This guards against double-counting (e.g. ~240+240) regressions.
    expect(wrapperSize.height, lessThan(320));
    expect(tester.takeException(), isNull);
  });
}
