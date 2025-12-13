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
  testWidgets('HtmlDiv border-image does not affect layout size', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 20, height: 20, color: Colors.red);
    });

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(80),
            boxSizing: HtmlBoxSizing.contentBox,
            border: HtmlBorder.all(
              width: const FixedBorderWidth(10),
              style: HtmlBorderStyle.solid,
              borderImage: HtmlBorderImage(
                image: MemoryImage(pngBytes),
                slice: const HtmlBorderImageSlice.all(
                  HtmlBorderImageSliceValue.percent(30),
                  fill: false,
                ),
                repeatX: HtmlBorderImageRepeat.repeat,
                repeatY: HtmlBorderImageRepeat.round,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final RenderBox renderBox = tester.renderObject(find.byType(HtmlDiv));
    // content 100x80 + border 10*2
    expect(renderBox.size, const Size(120, 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('HtmlDiv border-image paints without error with borderRadius', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 24, height: 24, color: Colors.blue);
    });

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(120),
            height: const FixedSize(60),
            border: HtmlBorder.all(
              width: const FixedBorderWidth(8),
              style: HtmlBorderStyle.solid,
              borderImage: HtmlBorderImage(
                image: MemoryImage(pngBytes),
                slice: const HtmlBorderImageSlice.all(
                  HtmlBorderImageSliceValue.px(6),
                  fill: true,
                ),
                width: const HtmlBorderImageSideValues.all(
                  HtmlBorderImageSideValue.auto(),
                ),
                outset: const HtmlBorderImageSideValues.all(
                  HtmlBorderImageSideValue.px(0),
                ),
                repeatX: HtmlBorderImageRepeat.space,
                repeatY: HtmlBorderImageRepeat.repeat,
              ),
            ),
            borderRadius: const HtmlBorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(HtmlDiv), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
