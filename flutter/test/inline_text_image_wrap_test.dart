import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

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

Widget _host({required double width, required List<Widget> inlineChildren}) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.noScaling),
      child: Center(
        child: HtmlDiv(
          key: const ValueKey('root'),
          width: FixedSize(width),
          height: const AutoSize(),
          border: HtmlBorder.all(width: const FixedBorderWidth(0)),
          children: inlineChildren,
        ),
      ),
    ),
  );
}

double _textFirstLineBaselineY(WidgetTester tester, Key key) {
  final Finder f = find.byKey(key);
  final RenderHtmlText r = tester.renderObject(f);
  final Offset topLeft = tester.getTopLeft(f);
  return topLeft.dy + r.firstLineBaselineFromTop;
}

double _textLastLineBaselineY(WidgetTester tester, Key key) {
  final Finder f = find.byKey(key);
  final RenderHtmlText r = tester.renderObject(f);
  final Offset topLeft = tester.getTopLeft(f);
  return topLeft.dy + r.lastLineBaselineFromTop;
}

double _imageBaselineY(WidgetTester tester, Key key) {
  final Finder f = find.byKey(key);
  final Offset topLeft = tester.getTopLeft(f);
  final Size size = tester.getSize(f);
  // RenderHtmlImage doesn't implement a custom baseline; our inline layout
  // treats its baseline as the bottom edge.
  return topLeft.dy + size.height;
}

double _boxBottomY(WidgetTester tester, Key key) {
  final Finder f = find.byKey(key);
  final Offset topLeft = tester.getTopLeft(f);
  final Size size = tester.getSize(f);
  return topLeft.dy + size.height;
}

void main() {
  // Ahem is a built-in test font with predictable glyph metrics.
  const TextStyle ahem10 = TextStyle(
    fontFamily: 'Ahem',
    fontSize: 10,
    height: 1.0,
  );

  testWidgets('fills remaining line space for trailing text after image', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.red);
    });

    await tester.pumpWidget(
      _host(
        width: 120,
        inlineChildren: [
          const HtmlText('aaaaa', key: ValueKey('t1'), style: ahem10), // ~50px
          HtmlImage(
            key: const ValueKey('img'),
            image: MemoryImage(pngBytes),
            width: const FixedSize(60),
            height: const FixedSize(20),
            placeholderSize: const Size(1, 1),
          ),
          const HtmlText(
            'bbbbbbbb',
            key: ValueKey('t2'),
            style: ahem10,
          ), // ~80px
        ],
      ),
    );

    await tester.pumpAndSettle();

    final Offset t1TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t1')),
    );
    final Offset t2TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t2')),
    );
    // Browser-like behavior: the trailing text box stays in the same inline run
    // (same line baseline), and only its internal layout wraps remaining text
    // onto subsequent lines.
    expect((t2TopLeft.dy - t1TopLeft.dy).abs(), lessThan(20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('wraps image as a whole when image does not fit line end', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.green);
    });

    await tester.pumpWidget(
      _host(
        width: 120,
        inlineChildren: [
          const HtmlText(
            'aaaaaaaaa',
            key: ValueKey('t1'),
            style: ahem10,
          ), // ~90px
          HtmlImage(
            key: const ValueKey('img'),
            image: MemoryImage(pngBytes),
            width: const FixedSize(60),
            height: const FixedSize(20),
            placeholderSize: const Size(1, 1),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    final Offset t1TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t1')),
    );
    final Offset imgTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('img')),
    );
    expect(imgTopLeft.dy, greaterThan(t1TopLeft.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('oversized image is constrained by available maxWidth', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.blue);
    });

    await tester.pumpWidget(
      _host(
        width: 80,
        inlineChildren: [
          HtmlImage(
            key: const ValueKey('img'),
            image: MemoryImage(pngBytes),
            width: const FixedSize(200),
            height: const FixedSize(20),
            placeholderSize: const Size(1, 1),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    final Size imgSize = tester.getSize(find.byKey(const ValueKey('img')));
    expect(imgSize.width, equals(80));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'long HtmlText that wraps internally forces following image onto next line',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(
          width: 2,
          height: 2,
          color: Colors.purple,
        );
      });

      await tester.pumpWidget(
        _host(
          width: 120,
          inlineChildren: [
            const HtmlText(
              'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
              key: ValueKey('t1'),
              style: ahem10,
            ),
            HtmlImage(
              key: const ValueKey('img'),
              image: MemoryImage(pngBytes),
              width: const FixedSize(30),
              height: const FixedSize(20),
              placeholderSize: const Size(1, 1),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      final Offset t1TopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('t1')),
      );
      final Offset imgTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('img')),
      );
      expect(imgTopLeft.dy, greaterThan(t1TopLeft.dy));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'regression: trailing wrapping HtmlText must not pull image baseline down',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.red);
      });

      // Arrange so that:
      // - t1 + img are on the first line
      // - t2 is the last inline in the run, and wraps internally (first line is
      //   measured in the remaining space, rest continues on next lines)
      await tester.pumpWidget(
        _host(
          width: 200,
          inlineChildren: [
            const HtmlText(
              'aaaaa',
              key: ValueKey('t1'),
              style: ahem10,
            ), // ~50px
            HtmlImage(
              key: const ValueKey('img'),
              image: MemoryImage(pngBytes),
              width: const FixedSize(90),
              height: const FixedSize(28),
              placeholderSize: const Size(1, 1),
            ),
            const HtmlText(
              'bbbbbbbbbbbbbbbbbbbb',
              key: ValueKey('t2'),
              style: ahem10,
            ), // wraps
          ],
        ),
      );

      await tester.pumpAndSettle();

      final RenderHtmlText t2 = tester.renderObject(
        find.byKey(const ValueKey('t2')),
      );
      final Offset t2TopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('t2')),
      );
      final double baselineYt1 = _textFirstLineBaselineY(
        tester,
        const ValueKey('t1'),
      );
      final double baselineYimg = _imageBaselineY(
        tester,
        const ValueKey('img'),
      );
      final double baselineYt2First =
          t2TopLeft.dy + t2.firstLineBaselineFromTop;

      // All boxes participating in the first line box should share the same
      // baseline. The key assertion: even though t2 wraps, its FIRST line
      // baseline is used for line alignment (so the image doesn't sink).
      expect((baselineYt1 - baselineYimg).abs(), lessThan(0.01));
      expect((baselineYt1 - baselineYt2First).abs(), lessThan(0.01));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'image after a multi-line HtmlText aligns to the text last-line baseline',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.cyan);
      });

      await tester.pumpWidget(
        _host(
          width: 120,
          inlineChildren: [
            const HtmlText(
              'aaaaaaaaaaaaaaaaaaaa',
              key: ValueKey('t1'),
              style: ahem10,
            ), // wraps
            HtmlImage(
              key: const ValueKey('img'),
              image: MemoryImage(pngBytes),
              width: const FixedSize(20),
              height: const FixedSize(20),
              placeholderSize: const Size(1, 1),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      final double baselineYt1 = _textLastLineBaselineY(
        tester,
        const ValueKey('t1'),
      );
      final double baselineYimg = _imageBaselineY(
        tester,
        const ValueKey('img'),
      );
      expect((baselineYt1 - baselineYimg).abs(), lessThan(0.01));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('naturalPixelSize drives auto width/height', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 20, height: 10, color: Colors.red);
    });

    await tester.pumpWidget(
      _host(
        width: 200,
        inlineChildren: [
          HtmlImage(
            key: const ValueKey('img'),
            image: MemoryImage(pngBytes),
            width: const AutoSize(),
            height: const AutoSize(),
            naturalPixelSize: const Size(20, 10),
            naturalPixelScale: 1.0,
            placeholderSize: const Size(1, 1),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    final Size imgSize = tester.getSize(find.byKey(const ValueKey('img')));
    expect(imgSize.width, equals(20));
    expect(imgSize.height, equals(10));
    expect(tester.takeException(), isNull);
  });

  testWidgets('naturalPixelScale maps pixels to logical size', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(
        width: 20,
        height: 10,
        color: Colors.green,
      );
    });

    await tester.pumpWidget(
      _host(
        width: 200,
        inlineChildren: [
          HtmlImage(
            key: const ValueKey('img'),
            image: MemoryImage(pngBytes),
            width: const AutoSize(),
            height: const AutoSize(),
            naturalPixelSize: const Size(20, 10),
            naturalPixelScale: 2.0,
            placeholderSize: const Size(1, 1),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    final Size imgSize = tester.getSize(find.byKey(const ValueKey('img')));
    expect(imgSize.width, equals(10));
    expect(imgSize.height, equals(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('auto-sized image wraps as a whole when it does not fit', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 30, height: 10, color: Colors.blue);
    });

    await tester.pumpWidget(
      _host(
        width: 50,
        inlineChildren: [
          const HtmlText('aaa', key: ValueKey('t1'), style: ahem10), // ~30px
          HtmlImage(
            key: const ValueKey('img'),
            image: MemoryImage(pngBytes),
            width: const AutoSize(),
            height: const AutoSize(),
            naturalPixelSize: const Size(30, 10),
            placeholderSize: const Size(1, 1),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    final Offset t1TopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('t1')),
    );
    final Offset imgTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('img')),
    );
    expect(imgTopLeft.dy, greaterThan(t1TopLeft.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mixed Text + span + Image shares the same first-line baseline', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(
        width: 20,
        height: 10,
        color: Colors.purple,
      );
    });

    await tester.pumpWidget(
      _host(
        width: 220,
        inlineChildren: [
          const HtmlText('x', key: ValueKey('t1'), style: ahem10),
          HtmlDiv(
            key: const ValueKey('span'),
            display: HtmlDisplay.inline,
            children: const [
              HtmlText('x', key: ValueKey('spanText'), style: ahem10),
            ],
          ),
          HtmlImage(
            key: const ValueKey('img'),
            image: MemoryImage(pngBytes),
            width: const AutoSize(),
            height: const AutoSize(),
            naturalPixelSize: const Size(20, 10),
            placeholderSize: const Size(1, 1),
          ),
          const HtmlText('x', key: ValueKey('t2'), style: ahem10),
        ],
      ),
    );

    await tester.pumpAndSettle();

    final double baselineYt1 = _textFirstLineBaselineY(
      tester,
      const ValueKey('t1'),
    );
    final double baselineYimg = _imageBaselineY(tester, const ValueKey('img'));
    final double baselineYSpanText = _textFirstLineBaselineY(
      tester,
      const ValueKey('spanText'),
    );

    expect((baselineYt1 - baselineYimg).abs(), lessThan(0.01));
    expect((baselineYt1 - baselineYSpanText).abs(), lessThan(0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('span-wrapped image uses span bottom edge as baseline', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 20, height: 10, color: Colors.teal);
    });

    await tester.pumpWidget(
      _host(
        width: 220,
        inlineChildren: [
          const HtmlText('x', key: ValueKey('t1'), style: ahem10),
          HtmlDiv(
            key: const ValueKey('span'),
            display: HtmlDisplay.inline,
            padding: HtmlPadding.only(
              top: HtmlLength.px(3),
              bottom: HtmlLength.px(4),
            ),
            children: [
              // Align with the HTML demo assumptions: prevent a font strut from
              // affecting the line box/baseline when this span only contains a
              // replaced element.
              const HtmlText('', style: TextStyle(fontSize: 0, height: 0)),
              HtmlImage(
                key: const ValueKey('img'),
                image: MemoryImage(pngBytes),
                width: const AutoSize(),
                height: const AutoSize(),
                naturalPixelSize: const Size(20, 10),
                placeholderSize: const Size(1, 1),
              ),
            ],
          ),
          const HtmlText('x', key: ValueKey('t2'), style: ahem10),
        ],
      ),
    );

    await tester.pumpAndSettle();

    final double baselineYt1 = _textFirstLineBaselineY(
      tester,
      const ValueKey('t1'),
    );
    final double baselineYt2 = _textFirstLineBaselineY(
      tester,
      const ValueKey('t2'),
    );
    final double bottomYSpan = _boxBottomY(tester, const ValueKey('span'));
    final double baselineYImg = _imageBaselineY(tester, const ValueKey('img'));

    // The inline layout aligns boxes on a shared line baseline.
    // For an inline span wrapper, its baseline is the bottom edge of its box.
    expect((baselineYt1 - bottomYSpan).abs(), lessThan(0.01));
    expect((baselineYt2 - bottomYSpan).abs(), lessThan(0.01));

    // The image is inside the span; with padding-bottom=4, its own bottom edge
    // sits 4px above the span baseline.
    final double delta = bottomYSpan - baselineYImg;
    expect(delta, greaterThan(0));
    expect(
      delta,
      closeTo(4, 0.75),
      reason:
          'delta=$delta bottomYSpan=$bottomYSpan baselineYImg=$baselineYImg',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline span padding affects line box height', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(
        width: 20,
        height: 10,
        color: Colors.orange,
      );
    });

    Future<double> pumpAndMeasureHeight({required bool padded}) async {
      await tester.pumpWidget(
        _host(
          width: 220,
          inlineChildren: [
            const HtmlText('x', key: ValueKey('t1'), style: ahem10),
            HtmlDiv(
              key: const ValueKey('span'),
              display: HtmlDisplay.inline,
              padding: padded
                  ? HtmlPadding.only(
                      top: HtmlLength.px(5),
                      bottom: HtmlLength.px(7),
                    )
                  : null,
              children: [
                HtmlImage(
                  key: const ValueKey('img'),
                  image: MemoryImage(pngBytes),
                  width: const FixedSize(20),
                  height: const FixedSize(10),
                  placeholderSize: const Size(1, 1),
                ),
              ],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      return tester.getSize(find.byKey(const ValueKey('root'))).height;
    }

    final double h0 = await pumpAndMeasureHeight(padded: false);
    final double h1 = await pumpAndMeasureHeight(padded: true);

    // padding-top+bottom should add to the line box height.
    expect((h1 - h0 - 12).abs(), lessThan(0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline span vertical margins affect line box height', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(
        width: 20,
        height: 10,
        color: Colors.indigo,
      );
    });

    Future<double> pumpAndMeasureHeight({
      required double marginTop,
      required double marginBottom,
    }) async {
      await tester.pumpWidget(
        _host(
          width: 220,
          inlineChildren: [
            const HtmlText('x', key: ValueKey('t1'), style: ahem10),
            HtmlDiv(
              key: const ValueKey('span'),
              display: HtmlDisplay.inline,
              margin: (marginTop == 0 && marginBottom == 0)
                  ? null
                  : HtmlMargin.only(
                      top: HtmlLength.px(marginTop),
                      bottom: HtmlLength.px(marginBottom),
                    ),
              children: [
                HtmlImage(
                  key: const ValueKey('img'),
                  image: MemoryImage(pngBytes),
                  width: const FixedSize(20),
                  height: const FixedSize(10),
                  placeholderSize: const Size(1, 1),
                ),
              ],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      return tester.getSize(find.byKey(const ValueKey('root'))).height;
    }

    final double h0 = await pumpAndMeasureHeight(marginTop: 0, marginBottom: 0);
    final double hTop = await pumpAndMeasureHeight(
      marginTop: 6,
      marginBottom: 0,
    );
    final double hBottom = await pumpAndMeasureHeight(
      marginTop: 0,
      marginBottom: 8,
    );
    final double hBoth = await pumpAndMeasureHeight(
      marginTop: 6,
      marginBottom: 8,
    );

    // We don't assert exact additivity here (baseline math/strut may affect it),
    // but both margins should increase the resulting line box height.
    expect(hTop, greaterThan(h0));
    expect(hBottom, greaterThan(h0));
    expect(hBoth, greaterThanOrEqualTo(hTop));
    expect(hBoth, greaterThanOrEqualTo(hBottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('textIndent shifts leading span-wrapped image on first line', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.brown);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.noScaling),
          child: Center(
            child: HtmlDiv(
              key: const ValueKey('root'),
              width: const FixedSize(200),
              height: const AutoSize(),
              textIndent: const HtmlLength.px(20),
              border: HtmlBorder.all(width: const FixedBorderWidth(0)),
              children: [
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  children: [
                    HtmlDiv(
                      key: const ValueKey('span'),
                      display: HtmlDisplay.inline,
                      children: [
                        HtmlImage(
                          key: const ValueKey('img'),
                          image: MemoryImage(pngBytes),
                          width: const FixedSize(20),
                          height: const FixedSize(10),
                          placeholderSize: const Size(1, 1),
                        ),
                      ],
                    ),
                    const HtmlText('xxxxx', key: ValueKey('t1'), style: ahem10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset rootTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('root')),
    );
    final Offset imgTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('img')),
    );
    expect((imgTopLeft.dx - rootTopLeft.dx - 20).abs(), lessThan(0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'regression: textIndent + span padding/margin + wrapping (indent only on first line)',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.pink);
      });

      // Use Ahem so each glyph is ~fontSize wide, making wrap deterministic.
      // Container width=160, textIndent=30 => firstLineMaxWidth=130.
      // Text is 16 chars => first line 13 chars, second line 3 chars.
      // Span outer width ~= margin(11+13) + padding(5+7) + image(120) = 156.
      // Remaining on 2nd line is 160 - 30 = 130, so span must wrap to next line.
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.noScaling),
            child: Center(
              child: HtmlDiv(
                key: const ValueKey('root'),
                width: const FixedSize(160),
                height: const AutoSize(),
                textIndent: const HtmlLength.px(30),
                border: HtmlBorder.all(width: const FixedBorderWidth(0)),
                children: [
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    children: [
                      const HtmlText(
                        'xxxxxxxxxxxxxxxx',
                        key: ValueKey('t1'),
                        style: ahem10,
                      ),
                      HtmlDiv(
                        key: const ValueKey('span'),
                        display: HtmlDisplay.inline,
                        margin: HtmlMargin.only(
                          left: HtmlLength.px(11),
                          right: HtmlLength.px(13),
                        ),
                        padding: HtmlPadding.only(
                          left: HtmlLength.px(5),
                          right: HtmlLength.px(7),
                        ),
                        children: [
                          // Prevent font strut from affecting the line box.
                          const HtmlText(
                            '',
                            style: TextStyle(fontSize: 0, height: 0),
                          ),
                          HtmlImage(
                            key: const ValueKey('img'),
                            image: MemoryImage(pngBytes),
                            width: const FixedSize(120),
                            height: const FixedSize(10),
                            placeholderSize: const Size(1, 1),
                          ),
                        ],
                      ),
                      const HtmlText('y', key: ValueKey('t2'), style: ahem10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Offset rootTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('root')),
      );
      final Offset spanTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('span')),
      );
      final Offset imgTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('img')),
      );
      final Offset t1TopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('t1')),
      );

      // Span should be wrapped to a later line.
      expect(spanTopLeft.dy, greaterThan(t1TopLeft.dy));

      // Key assertion: wrapped lines should not carry textIndent.
      // The span is at line start + margin-left (11), not indent(30) + margin-left.
      expect((spanTopLeft.dx - rootTopLeft.dx - 11).abs(), lessThan(0.01));

      // The image should be placed after span padding-left.
      expect((imgTopLeft.dx - spanTopLeft.dx - 5).abs(), lessThan(0.01));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('textAlign positions a single-line mixed (text+image) run', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.teal);
    });

    Future<void> pumpAndAssert({
      required HtmlTextAlign textAlign,
      required double expectedStartDx,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.noScaling),
            child: Center(
              child: HtmlDiv(
                key: const ValueKey('root'),
                width: const FixedSize(160),
                height: const AutoSize(),
                textAlign: textAlign,
                border: HtmlBorder.all(width: const FixedBorderWidth(0)),
                children: [
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    children: [
                      const HtmlText(
                        'xxxx',
                        key: ValueKey('t1'),
                        style: ahem10,
                      ),
                      HtmlImage(
                        key: const ValueKey('img'),
                        image: MemoryImage(pngBytes),
                        width: const FixedSize(20),
                        height: const FixedSize(10),
                        placeholderSize: const Size(1, 1),
                      ),
                      const HtmlText('yy', key: ValueKey('t2'), style: ahem10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // With Ahem10: 'xxxx' ~ 40px, image 20px, 'yy' ~ 20px => total ~ 80px.
      // For width=160: start=0, center=(160-80)/2=40, end=(160-80)=80.
      final Offset rootTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('root')),
      );
      final Offset t1TopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('t1')),
      );
      expect(
        (t1TopLeft.dx - rootTopLeft.dx - expectedStartDx).abs(),
        lessThan(0.01),
      );
      expect(tester.takeException(), isNull);
    }

    await pumpAndAssert(textAlign: HtmlTextAlign.start, expectedStartDx: 0);
    await pumpAndAssert(textAlign: HtmlTextAlign.center, expectedStartDx: 40);
    await pumpAndAssert(textAlign: HtmlTextAlign.end, expectedStartDx: 80);
  });

  testWidgets('textAlign keeps image between text spans (single-line)', (
    WidgetTester tester,
  ) async {
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      pngBytes = await _makeSolidPng(width: 2, height: 2, color: Colors.cyan);
    });

    Future<void> pumpAndAssert({
      required HtmlTextAlign textAlign,
      required double expectedStartDx,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.noScaling),
            child: Center(
              child: HtmlDiv(
                key: const ValueKey('root'),
                width: const FixedSize(160),
                height: const AutoSize(),
                textAlign: textAlign,
                border: HtmlBorder.all(width: const FixedBorderWidth(0)),
                children: [
                  const HtmlText('xxxx', key: ValueKey('t1'), style: ahem10),
                  HtmlImage(
                    key: const ValueKey('img'),
                    image: MemoryImage(pngBytes),
                    width: const FixedSize(20),
                    height: const FixedSize(10),
                    placeholderSize: const Size(1, 1),
                  ),
                  const HtmlText('yy', key: ValueKey('t2'), style: ahem10),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

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

      // With Ahem10: 'xxxx' ~ 40px. The image should start right after it.
      expect(
        (imgTopLeft.dx - rootTopLeft.dx - (expectedStartDx + 40)).abs(),
        lessThan(0.01),
      );
      // And 'yy' should start after image width (20px).
      expect(
        (t2TopLeft.dx - rootTopLeft.dx - (expectedStartDx + 40 + 20)).abs(),
        lessThan(0.01),
      );
      // Sanity: order is preserved.
      expect(t1TopLeft.dx, lessThan(imgTopLeft.dx));
      expect(imgTopLeft.dx, lessThan(t2TopLeft.dx));
      expect(tester.takeException(), isNull);
    }

    await pumpAndAssert(textAlign: HtmlTextAlign.center, expectedStartDx: 40);
    await pumpAndAssert(textAlign: HtmlTextAlign.end, expectedStartDx: 80);
  });

  testWidgets('textAlign centers/ends a single-line text-only run', (
    WidgetTester tester,
  ) async {
    Future<void> pumpAndAssert({
      required HtmlTextAlign textAlign,
      required double expectedStartDx,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.noScaling),
            child: Center(
              child: HtmlDiv(
                key: const ValueKey('root'),
                width: const FixedSize(200),
                height: const AutoSize(),
                textAlign: textAlign,
                border: HtmlBorder.all(width: const FixedBorderWidth(0)),
                children: const [
                  HtmlText('Hello ', key: ValueKey('t1'), style: ahem10),
                  HtmlText('world', key: ValueKey('t2'), style: ahem10),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // With Ahem10: 'Hello ' ~ 60px, 'world' ~ 50px => total ~ 110px.
      // For width=200: start=0, center=(200-110)/2=45, end=(200-110)=90.
      final Offset rootTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('root')),
      );
      final Offset t1TopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('t1')),
      );
      final Offset t2TopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('t2')),
      );

      expect(
        (t1TopLeft.dx - rootTopLeft.dx - expectedStartDx).abs(),
        lessThan(0.01),
      );
      expect(t1TopLeft.dx, lessThan(t2TopLeft.dx));
      expect(tester.takeException(), isNull);
    }

    await pumpAndAssert(textAlign: HtmlTextAlign.center, expectedStartDx: 45);
    await pumpAndAssert(textAlign: HtmlTextAlign.end, expectedStartDx: 90);
  });

  testWidgets('lineHeight on nested inline HtmlDiv does not force wrapping', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.noScaling),
          child: Center(
            child: HtmlDiv(
              width: FixedSize(320),
              height: AutoSize(),
              textAlign: HtmlTextAlign.start,
              border: HtmlBorder.all(width: FixedBorderWidth(0)),
              children: [
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  lineHeight: HtmlLength.px(14),
                  children: [
                    HtmlText(
                      '轻之国度录入组',
                      key: ValueKey('tLeft'),
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
                HtmlText('x', style: TextStyle(fontSize: 14, height: 1.4)),
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  lineHeight: HtmlLength.px(22),
                  children: [
                    HtmlText(
                      '虚空文学旅团',
                      key: ValueKey('tRight'),
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

    final RenderHtmlText left = tester.renderObject(
      find.byKey(const ValueKey('tLeft')),
    );
    final RenderHtmlText right = tester.renderObject(
      find.byKey(const ValueKey('tRight')),
    );

    expect(left.debugLineCount, 1);
    expect(right.debugLineCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'lineHeight does not force wrapping when parent HtmlDiv is inline',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.noScaling),
            child: Center(
              child: HtmlDiv(
                display: HtmlDisplay.inline,
                width: const FixedSize(320),
                height: const AutoSize(),
                textAlign: HtmlTextAlign.start,
                border: HtmlBorder.all(width: const FixedBorderWidth(0)),
                children: [
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    lineHeight: HtmlLength.px(14),
                    children: const [
                      HtmlText(
                        '轻之国度录入组',
                        key: ValueKey('pInline.left'),
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                  const HtmlText(
                    'x',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    lineHeight: HtmlLength.px(22),
                    children: const [
                      HtmlText(
                        '虚空文学旅团',
                        key: ValueKey('pInline.right'),
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

      final RenderHtmlText left = tester.renderObject(
        find.byKey(const ValueKey('pInline.left')),
      );
      final RenderHtmlText right = tester.renderObject(
        find.byKey(const ValueKey('pInline.right')),
      );

      expect(left.debugLineCount, 1);
      expect(right.debugLineCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'textAlign center/end keeps image between spans when first text ends with space',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(
          width: 2,
          height: 2,
          color: Colors.lightBlue,
        );
      });

      Future<void> pumpAndAssert({
        required HtmlTextAlign textAlign,
        required double expectedStartDx,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.noScaling),
              child: Center(
                child: HtmlDiv(
                  key: const ValueKey('root'),
                  width: const FixedSize(200),
                  height: const AutoSize(),
                  textAlign: textAlign,
                  border: HtmlBorder.all(width: const FixedBorderWidth(0)),
                  children: [
                    const HtmlText(
                      'Hello ',
                      key: ValueKey('t1'),
                      style: ahem10,
                    ),
                    HtmlImage(
                      key: const ValueKey('img'),
                      image: MemoryImage(pngBytes),
                      width: const FixedSize(20),
                      height: const FixedSize(10),
                      placeholderSize: const Size(1, 1),
                    ),
                    const HtmlText('world', key: ValueKey('t2'), style: ahem10),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

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

        // With Ahem10: each char ~10px. 'Hello ' => 60px, img 20px, 'world' => 50px.
        // Total ~130px. For width=200: center start=(200-130)/2=35; end start=(200-130)=70.
        expect(
          (t1TopLeft.dx - rootTopLeft.dx - expectedStartDx).abs(),
          lessThan(0.01),
        );
        expect(
          (imgTopLeft.dx - rootTopLeft.dx - (expectedStartDx + 60)).abs(),
          lessThan(0.01),
        );
        expect(
          (t2TopLeft.dx - rootTopLeft.dx - (expectedStartDx + 60 + 20)).abs(),
          lessThan(0.01),
        );
        expect(t1TopLeft.dx, lessThan(imgTopLeft.dx));
        expect(imgTopLeft.dx, lessThan(t2TopLeft.dx));
        expect(tester.takeException(), isNull);
      }

      await pumpAndAssert(textAlign: HtmlTextAlign.center, expectedStartDx: 35);
      await pumpAndAssert(textAlign: HtmlTextAlign.end, expectedStartDx: 70);
    },
  );

  testWidgets(
    'textAlign.center + textIndent: wrapped non-first line is centered (mixed text+image)',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(
          width: 2,
          height: 2,
          color: Colors.orange,
        );
      });

      // Width=160, indent=30 => first line maxWidth=130.
      // First text is 13 chars => exactly fills first line.
      // Second line: span(image 40) + 'xxxx'(40) => ~80px; centered => start ~40.
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.noScaling),
            child: Center(
              child: HtmlDiv(
                key: const ValueKey('root'),
                width: const FixedSize(160),
                height: const AutoSize(),
                textAlign: HtmlTextAlign.center,
                textIndent: const HtmlLength.px(30),
                border: HtmlBorder.all(width: const FixedBorderWidth(0)),
                children: [
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    children: [
                      const HtmlText(
                        'xxxxxxxxxxxxx',
                        key: ValueKey('t1'),
                        style: ahem10,
                      ),
                      HtmlDiv(
                        key: const ValueKey('span'),
                        display: HtmlDisplay.inline,
                        padding: HtmlPadding.only(left: HtmlLength.px(5)),
                        children: [
                          const HtmlText(
                            '',
                            style: TextStyle(fontSize: 0, height: 0),
                          ),
                          HtmlImage(
                            key: const ValueKey('img'),
                            image: MemoryImage(pngBytes),
                            width: const FixedSize(40),
                            height: const FixedSize(10),
                            placeholderSize: const Size(1, 1),
                          ),
                        ],
                      ),
                      const HtmlText(
                        'xxxx',
                        key: ValueKey('t2'),
                        style: ahem10,
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

      final Rect rootRect = tester.getRect(find.byKey(const ValueKey('root')));
      final Rect t1Rect = tester.getRect(find.byKey(const ValueKey('t1')));
      final Rect spanRect = tester.getRect(find.byKey(const ValueKey('span')));
      final Rect t2Rect = tester.getRect(find.byKey(const ValueKey('t2')));
      final Offset spanTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('span')),
      );
      final Offset imgTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('img')),
      );

      // Ensure wrap happened: span is on a later line than the first text.
      expect(spanRect.top, greaterThan(t1Rect.top));

      // Center alignment check for the wrapped (non-first) line:
      // use actual geometry bounds of the two widgets participating on that line.
      final double lineLeft = math.min(spanRect.left, t2Rect.left);
      final double lineRight = math.max(spanRect.right, t2Rect.right);
      final double lineCenter = (lineLeft + lineRight) / 2.0;
      final double rootCenter = (rootRect.left + rootRect.right) / 2.0;
      expect((lineCenter - rootCenter).abs(), lessThan(0.01));

      // The image should still be placed after span padding-left.
      expect((imgTopLeft.dx - spanTopLeft.dx - 5).abs(), lessThan(0.01));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'textAlign.end + textIndent: wrapped non-first line is right-aligned (mixed text+image)',
    (WidgetTester tester) async {
      late Uint8List pngBytes;
      await tester.runAsync(() async {
        pngBytes = await _makeSolidPng(
          width: 2,
          height: 2,
          color: Colors.indigo,
        );
      });

      // Same structure as the center test, but we assert right edge alignment.
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.noScaling),
            child: Center(
              child: HtmlDiv(
                key: const ValueKey('root'),
                width: const FixedSize(160),
                height: const AutoSize(),
                textAlign: HtmlTextAlign.end,
                textIndent: const HtmlLength.px(30),
                border: HtmlBorder.all(width: const FixedBorderWidth(0)),
                children: [
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    children: [
                      const HtmlText(
                        'xxxxxxxxxxxxx',
                        key: ValueKey('t1'),
                        style: ahem10,
                      ),
                      HtmlDiv(
                        key: const ValueKey('span'),
                        display: HtmlDisplay.inline,
                        margin: HtmlMargin.only(left: HtmlLength.px(11)),
                        padding: HtmlPadding.only(left: HtmlLength.px(5)),
                        children: [
                          const HtmlText(
                            '',
                            style: TextStyle(fontSize: 0, height: 0),
                          ),
                          HtmlImage(
                            key: const ValueKey('img'),
                            image: MemoryImage(pngBytes),
                            width: const FixedSize(40),
                            height: const FixedSize(10),
                            placeholderSize: const Size(1, 1),
                          ),
                        ],
                      ),
                      const HtmlText(
                        'xxxx',
                        key: ValueKey('t2'),
                        style: ahem10,
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

      final Rect rootRect = tester.getRect(find.byKey(const ValueKey('root')));
      final Rect t1Rect = tester.getRect(find.byKey(const ValueKey('t1')));
      final Rect spanRect = tester.getRect(find.byKey(const ValueKey('span')));
      final Rect t2Rect = tester.getRect(find.byKey(const ValueKey('t2')));
      final Offset spanTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('span')),
      );
      final Offset imgTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('img')),
      );

      expect(spanRect.top, greaterThan(t1Rect.top));

      final double lineRight = math.max(spanRect.right, t2Rect.right);
      expect((lineRight - rootRect.right).abs(), lessThan(0.01));

      // No indent should leak onto the wrapped line; margin-left should remain.
      // We don't assert an absolute dx for right alignment, but ensure the
      // image-in-span internal padding is preserved.
      expect((imgTopLeft.dx - spanTopLeft.dx - 5).abs(), lessThan(0.01));
      expect(tester.takeException(), isNull);
    },
  );
}
