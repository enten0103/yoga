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
  testWidgets(
    'HtmlImage: naturalPixelSize respects clamped used width (height auto)',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.red);
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 80, // tight width constraint
              child: HtmlImage(
                key: const ValueKey('img'),
                image: MemoryImage(pngBytes),
                width: const FixedSize(200),
                height: const AutoSize(),
                // Declare the natural size to avoid async probing.
                naturalPixelSize: const Size(100, 50),
                naturalPixelScale: 1.0,
                // Keep placeholder non-zero to keep the layout path stable.
                placeholderSize: const Size(1, 1),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Size imgSize = tester.getSize(find.byKey(const ValueKey('img')));
      expect(imgSize.width, equals(80));
      expect(imgSize.height, equals(40));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'HtmlImage: naturalPixelSize respects clamped used height (width auto)',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(
          width: 2,
          height: 2,
          color: Colors.green,
        );
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              height: 90, // tight height constraint
              child: HtmlImage(
                key: const ValueKey('img'),
                image: MemoryImage(pngBytes),
                width: const AutoSize(),
                height: const FixedSize(200),
                naturalPixelSize: const Size(100, 50),
                naturalPixelScale: 1.0,
                placeholderSize: const Size(1, 1),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Size imgSize = tester.getSize(find.byKey(const ValueKey('img')));
      expect(imgSize.height, equals(90));
      expect(imgSize.width, equals(180));
      expect(tester.takeException(), isNull);
    },
  );
}
