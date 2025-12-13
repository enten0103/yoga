import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

Color _pixelAt(ByteData data, int width, int x, int y) {
  final int index = (y * width + x) * 4;
  final int r = data.getUint8(index);
  final int g = data.getUint8(index + 1);
  final int b = data.getUint8(index + 2);
  final int a = data.getUint8(index + 3);
  return Color.fromARGB(a, r, g, b);
}

Future<ui.Image> _capture(WidgetTester tester, GlobalKey boundaryKey) async {
  final RenderRepaintBoundary boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final ui.Image? image = await tester.runAsync<ui.Image?>(
    () => boundary.toImage(pixelRatio: 1.0),
  );
  return image!;
}

Future<ByteData> _rawRgba(WidgetTester tester, ui.Image image) async {
  final ByteData? data = await tester.runAsync<ByteData?>(
    () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
  );
  return data!;
}

void main() {
  testWidgets('later sibling paints on top when overlapping', (
    WidgetTester tester,
  ) async {
    final GlobalKey boundaryKey = GlobalKey();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: HtmlDiv(
              width: const FixedSize(120),
              height: const FixedSize(200),
              border: HtmlBorder.all(width: const FixedBorderWidth(0)),
              children: const [
                HtmlDiv(
                  width: FixedSize(100),
                  height: FixedSize(100),
                  background: HtmlBackground(color: Colors.red),
                ),
                HtmlDiv(
                  width: FixedSize(100),
                  height: FixedSize(100),
                  margin: HtmlMargin(top: HtmlLength.px(-50)),
                  background: HtmlBackground(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final ui.Image image = await _capture(tester, boundaryKey);
    addTearDown(image.dispose);

    final ByteData data = await _rawRgba(tester, image);

    // Overlap region: first box is at y=[0,100), second at y=[50,150).
    final Color pixel = _pixelAt(data, image.width, 50, 75);
    expect(pixel.toARGB32(), equals(Colors.blue.toARGB32()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('inline paints above overlapping block backgrounds', (
    WidgetTester tester,
  ) async {
    final GlobalKey boundaryKey = GlobalKey();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: HtmlDiv(
              width: const FixedSize(120),
              height: const FixedSize(220),
              border: HtmlBorder.all(width: const FixedBorderWidth(0)),
              children: const [
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  width: FixedSize(100),
                  height: FixedSize(100),
                  background: HtmlBackground(color: Colors.red),
                ),
                HtmlDiv(
                  width: FixedSize(100),
                  height: FixedSize(100),
                  margin: HtmlMargin(top: HtmlLength.px(-50)),
                  background: HtmlBackground(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final ui.Image image = await _capture(tester, boundaryKey);
    addTearDown(image.dispose);

    final ByteData data = await _rawRgba(tester, image);

    // Overlap region: inline box is at y=[0,100), block box at y=[50,150).
    // Inline should paint on top.
    final Color pixel = _pixelAt(data, image.width, 50, 75);
    expect(pixel.toARGB32(), equals(Colors.red.toARGB32()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('transparent block with inline content paints above later blocks', (
    WidgetTester tester,
  ) async {
    final GlobalKey boundaryKey = GlobalKey();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: HtmlDiv(
              width: const FixedSize(120),
              height: const FixedSize(220),
              border: HtmlBorder.all(width: const FixedBorderWidth(0)),
              children: const [
                // A block wrapper that contains inline content (like a <p>). It has
                // no background/border/shadow and should paint in the inline layer.
                HtmlDiv(
                  children: [
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      width: FixedSize(100),
                      height: FixedSize(100),
                      background: HtmlBackground(color: Colors.red),
                    ),
                  ],
                ),
                HtmlDiv(
                  width: FixedSize(100),
                  height: FixedSize(100),
                  margin: HtmlMargin(top: HtmlLength.px(-50)),
                  background: HtmlBackground(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final ui.Image image = await _capture(tester, boundaryKey);
    addTearDown(image.dispose);

    final ByteData data = await _rawRgba(tester, image);

    // Overlap region: second block overlaps upwards. Red inline content should
    // still be visible above the blue background.
    final Color pixel = _pixelAt(data, image.width, 50, 75);
    expect(pixel.toARGB32(), equals(Colors.red.toARGB32()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('earlier sibling is under later sibling when overlapping', (
    WidgetTester tester,
  ) async {
    final GlobalKey boundaryKey = GlobalKey();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: HtmlDiv(
              width: const FixedSize(120),
              height: const FixedSize(200),
              border: HtmlBorder.all(width: const FixedBorderWidth(0)),
              children: const [
                HtmlDiv(
                  width: FixedSize(100),
                  height: FixedSize(100),
                  background: HtmlBackground(color: Colors.blue),
                ),
                HtmlDiv(
                  width: FixedSize(100),
                  height: FixedSize(100),
                  margin: HtmlMargin(top: HtmlLength.px(-50)),
                  background: HtmlBackground(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final ui.Image image = await _capture(tester, boundaryKey);
    addTearDown(image.dispose);

    final ByteData data = await _rawRgba(tester, image);

    final Color pixel = _pixelAt(data, image.width, 50, 75);
    expect(pixel.toARGB32(), equals(Colors.red.toARGB32()));

    expect(tester.takeException(), isNull);
  });
}
