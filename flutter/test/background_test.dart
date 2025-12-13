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
  testWidgets('HtmlDiv background-color does not affect layout size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(80),
            boxSizing: HtmlBoxSizing.contentBox,
            background: const HtmlBackground(color: Colors.green),
            border: HtmlBorder.all(
              width: const FixedBorderWidth(10),
              style: HtmlBorderStyle.solid,
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

  testWidgets(
    'HtmlDiv background-image paints without error (repeat/clip/radius)',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(
          width: 16,
          height: 16,
          color: Colors.purple,
        );
      });

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: HtmlDiv(
              width: const FixedSize(140),
              height: const FixedSize(90),
              background: HtmlBackground(
                color: Colors.black12,
                clip: HtmlBackgroundClip.paddingBox,
                image: HtmlBackgroundImage(
                  image: MemoryImage(pngBytes),
                  repeatX: HtmlBackgroundRepeat.space,
                  repeatY: HtmlBackgroundRepeat.round,
                  size: const HtmlBackgroundSize.explicit(
                    width: HtmlLength.px(18),
                    height: HtmlLength.px(18),
                  ),
                  position: const HtmlBackgroundPosition(
                    alignment: Alignment.topLeft,
                    offset: HtmlLengthOffset(
                      dx: HtmlLength.px(3),
                      dy: HtmlLength.px(5),
                    ),
                  ),
                ),
              ),
              border: HtmlBorder.all(
                width: const FixedBorderWidth(10),
                style: HtmlBorderStyle.solid,
                color: Colors.blue,
              ),
              borderRadius: const HtmlBorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(HtmlDiv), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'HtmlDiv background variants do not throw (repeat/size/position/clip)',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(width: 8, height: 8, color: Colors.red);
      });

      final List<HtmlBackground> backgrounds = <HtmlBackground>[
        const HtmlBackground(
          color: Color(0xFFEEEEEE),
          clip: HtmlBackgroundClip.borderBox,
        ),
        const HtmlBackground(
          color: Color(0xFFEEEEEE),
          clip: HtmlBackgroundClip.paddingBox,
        ),
        HtmlBackground(
          image: HtmlBackgroundImage(
            image: MemoryImage(pngBytes),
            repeatX: HtmlBackgroundRepeat.repeat,
            repeatY: HtmlBackgroundRepeat.repeat,
            size: const HtmlBackgroundSize.auto(),
            position: const HtmlBackgroundPosition(
              alignment: Alignment.topLeft,
            ),
          ),
        ),
        HtmlBackground(
          image: HtmlBackgroundImage(
            image: MemoryImage(pngBytes),
            repeatX: HtmlBackgroundRepeat.noRepeat,
            repeatY: HtmlBackgroundRepeat.noRepeat,
            size: const HtmlBackgroundSize.contain(),
            position: const HtmlBackgroundPosition(
              alignment: Alignment.center,
              offset: HtmlLengthOffset(
                dx: HtmlLength.px(6),
                dy: HtmlLength.px(4),
              ),
            ),
          ),
        ),
        HtmlBackground(
          image: HtmlBackgroundImage(
            image: MemoryImage(pngBytes),
            repeatX: HtmlBackgroundRepeat.round,
            repeatY: HtmlBackgroundRepeat.space,
            size: const HtmlBackgroundSize.cover(),
            position: const HtmlBackgroundPosition(
              alignment: Alignment.bottomRight,
            ),
          ),
        ),
        HtmlBackground(
          color: const Color(0x22000000),
          image: HtmlBackgroundImage(
            image: MemoryImage(pngBytes),
            repeatX: HtmlBackgroundRepeat.space,
            repeatY: HtmlBackgroundRepeat.round,
            size: const HtmlBackgroundSize.explicit(
              width: HtmlLength.px(12),
              height: HtmlLength.px(10),
            ),
            position: const HtmlBackgroundPosition(
              alignment: Alignment.centerLeft,
            ),
          ),
          clip: HtmlBackgroundClip.paddingBox,
        ),
      ];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListView.builder(
            itemCount: backgrounds.length,
            itemBuilder: (context, index) {
              final bg = backgrounds[index];
              return Padding(
                padding: const EdgeInsets.all(8),
                child: HtmlDiv(
                  width: const FixedSize(180),
                  height: const FixedSize(70),
                  background: bg,
                  border: HtmlBorder.all(
                    width: const FixedBorderWidth(10),
                    style: HtmlBorderStyle.solid,
                    color: const Color(0xFF000000),
                  ),
                  borderRadius: index.isEven
                      ? const HtmlBorderRadius.all(Radius.circular(14))
                      : null,
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(HtmlDiv), findsNWidgets(backgrounds.length));
      expect(tester.takeException(), isNull);
    },
  );
}
