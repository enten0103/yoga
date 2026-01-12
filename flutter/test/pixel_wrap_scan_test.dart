import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

const Color _kRed = Color(0xFFFF0000);

/// Pixel-scan based wrap detection.
///
/// We render a constrained HtmlDiv into a RepaintBoundary and scan for pixels
/// matching a given color. If those pixels span multiple lines vertically,
/// wrapping has happened.
class _PixelScan {
  static (int minY, int maxY)? verticalSpanForColor(
    _RgbaImage image, {
    required Color target,
    int tolerance = 70,
    int alphaMin = 10,
  }) {
    final int tr = (target.r * 255.0).round().clamp(0, 255);
    final int tg = (target.g * 255.0).round().clamp(0, 255);
    final int tb = (target.b * 255.0).round().clamp(0, 255);

    final Uint8List bytes = image.bytes;

    int minY = 1 << 30;
    int maxY = -1;

    bool close(int a, int b) => (a - b).abs() <= tolerance;

    for (int y = 0; y < image.height; y++) {
      final int rowStart = y * image.width * 4;
      for (int x = 0; x < image.width; x++) {
        final int i = rowStart + x * 4;
        final int r = bytes[i];
        final int g = bytes[i + 1];
        final int b = bytes[i + 2];
        final int a = bytes[i + 3];
        if (a < alphaMin) continue;

        if (close(r, tr) && close(g, tg) && close(b, tb)) {
          minY = math.min(minY, y);
          maxY = math.max(maxY, y);
        }
      }
    }

    if (maxY < 0) return null;
    return (minY, maxY);
  }
}

class _RgbaImage {
  const _RgbaImage(this.width, this.height, this.bytes);

  final int width;
  final int height;
  final Uint8List bytes;
}

Future<_RgbaImage?> _captureRgba(
  WidgetTester tester, {
  required Key boundaryKey,
  double pixelRatio = 1.0,
}) async {
  final RenderRepaintBoundary boundary = tester.renderObject(
    find.byKey(boundaryKey),
  );

  return tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? bd = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (bd == null) {
      throw StateError('Image.toByteData() returned null');
    }
    final Uint8List bytes = Uint8List.fromList(bd.buffer.asUint8List());
    image.dispose();
    return _RgbaImage(image.width, image.height, bytes);
  });
}

Widget _wrapInTestApp(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  );
}

Widget _wrapInInlineContainer(Widget child) {
  return HtmlDiv(
    key: const ValueKey('inlineWrapper'),
    display: HtmlDisplay.inline,
    children: [child],
  );
}

String _repeatText(String unit, int count) {
  return List<String>.filled(count, unit).join();
}

double _measureTextWidth(String text, TextStyle style) {
  final TextPainter tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: double.infinity);
  return tp.width;
}

String _randomLatinWord(math.Random rng, {int min = 1, int max = 10}) {
  const String alphabet = 'abcdefghijklmnopqrstuvwxyz';
  final int len = min + rng.nextInt(max - min + 1);
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < len; i++) {
    final int idx = rng.nextInt(alphabet.length);
    final String ch = alphabet[idx];
    b.write(rng.nextBool() ? ch : ch.toUpperCase());
  }
  return b.toString();
}

String _randomDigits(math.Random rng, {int min = 1, int max = 4}) {
  const String digits = '0123456789';
  final int len = min + rng.nextInt(max - min + 1);
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < len; i++) {
    b.write(digits[rng.nextInt(digits.length)]);
  }
  return b.toString();
}

String _randomCjkRun(math.Random rng, {int min = 1, int max = 6}) {
  const List<String> cjk = <String>[
    '中',
    '文',
    '测',
    '试',
    '汉',
    '字',
    '换',
    '行',
    '标',
    '点',
    '混',
    '排',
  ];
  final int len = min + rng.nextInt(max - min + 1);
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < len; i++) {
    b.write(cjk[rng.nextInt(cjk.length)]);
  }
  return b.toString();
}

String _randomPunct(math.Random rng) {
  const List<String> punct = <String>[
    ',',
    '.',
    '!',
    '?',
    ';',
    ':',
    '-',
    '_',
    '/',
    '\\',
    '(',
    ')',
    '[',
    ']',
    '{',
    '}',
    '，',
    '。',
    '！',
    '？',
    '；',
    '：',
    '—',
    '…',
    '（',
    '）',
  ];
  return punct[rng.nextInt(punct.length)];
}

String _randomMixedText(math.Random rng) {
  final List<String> tokens = <String>[];
  bool hasCjk = false;
  bool hasLatin = false;
  bool hasPunct = false;

  final int tokenCount = 6 + rng.nextInt(10); // 6..15
  for (int i = 0; i < tokenCount; i++) {
    final int kind = rng.nextInt(100);
    if (kind < 35) {
      tokens.add(_randomCjkRun(rng));
      hasCjk = true;
    } else if (kind < 70) {
      tokens.add(_randomLatinWord(rng));
      hasLatin = true;
    } else if (kind < 80) {
      tokens.add(_randomDigits(rng));
    } else if (kind < 95) {
      tokens.add(_randomPunct(rng));
      hasPunct = true;
    } else {
      tokens.add(' ');
    }
  }

  // Ensure the mix is present.
  if (!hasCjk) {
    tokens.insert(rng.nextInt(tokens.length + 1), _randomCjkRun(rng));
  }
  if (!hasLatin) {
    tokens.insert(rng.nextInt(tokens.length + 1), _randomLatinWord(rng));
  }
  if (!hasPunct) {
    tokens.insert(rng.nextInt(tokens.length + 1), _randomPunct(rng));
  }

  // Normalize whitespace: collapse multiple spaces and trim.
  final String joined = tokens.join();
  return joined.replaceAll(RegExp(r'\s+'), ' ').trim();
}

Future<void> _runRandomMixedNoWrapCases(
  WidgetTester tester, {
  required int cases,
  required int seed,
}) async {
  await _runRandomMixedNoWrapCasesWithBoxModel(
    tester,
    cases: cases,
    seed: seed,
    viewportMaxWidth: 1200,
    borderWidthPx: 1,
    paddingPx: 8,
    marginPx: 0,
    lineHeightPx: 40,
    boxSizing: HtmlBoxSizing.contentBox,
  );
}

Future<void> _runRandomMixedNoWrapCasesWithBoxModel(
  WidgetTester tester, {
  required int cases,
  required int seed,
  required double viewportMaxWidth,
  required double borderWidthPx,
  required double paddingPx,
  required double marginPx,
  required double lineHeightPx,
  required HtmlBoxSizing boxSizing,
}) async {
  const Key boundaryKey = ValueKey('boundary');
  final double horizontalInset =
      marginPx * 2 + borderWidthPx * 2 + paddingPx * 2;
  final double contentMaxWidth = viewportMaxWidth - horizontalInset;

  const TextStyle redStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: _kRed,
  );

  final math.Random rng = math.Random(seed);

  // Pre-generate strings that should fit within the max width to avoid
  // "expected" wrapping due to constraints.
  final List<String> texts = <String>[];
  int guard = 0;
  while (texts.length < cases && guard++ < cases * 200) {
    final String t = _randomMixedText(rng);
    if (t.isEmpty) continue;

    final double w = _measureTextWidth(t, redStyle);
    if (w.isFinite && w < contentMaxWidth - 2) {
      texts.add(t);
    }
  }
  expect(
    texts.length,
    cases,
    reason: 'Not enough generated strings fit within contentMaxWidth',
  );

  // Alternate between fit-content and inline shrink-to-fit.
  for (int i = 0; i < texts.length; i++) {
    final bool useFitContent = i.isEven;
    final String text = texts[i];

    await tester.pumpWidget(
      _wrapInTestApp(
        RepaintBoundary(
          key: boundaryKey,
          child: _wrapInInlineContainer(
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: viewportMaxWidth),
              child: HtmlDiv(
                width: useFitContent ? const FitContent() : const AutoSize(),
                height: const AutoSize(),
                boxSizing: boxSizing,
                margin: HtmlMargin.all(HtmlLength.px(marginPx)),
                border: HtmlBorder.all(width: FixedBorderWidth(borderWidthPx)),
                padding: HtmlPadding.all(HtmlLength.px(paddingPx)),
                lineHeight: HtmlLength.px(lineHeightPx),
                // default: normal
                children: [
                  if (useFitContent)
                    Text(text, style: redStyle)
                  else
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      children: [Text(text, style: redStyle)],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final _RgbaImage image = (await _captureRgba(
      tester,
      boundaryKey: boundaryKey,
    ))!;
    final (int minY, int maxY)? span = _PixelScan.verticalSpanForColor(
      image,
      target: _kRed,
      tolerance: 90,
      alphaMin: 10,
    );

    expect(span, isNotNull, reason: 'i=$i text="$text"');
    final int height = span!.$2 - span.$1;

    // Single line expected.
    expect(height, lessThan(60), reason: 'i=$i fitContent=$useFitContent');
  }
}

class _BoxModelCase {
  const _BoxModelCase({
    required this.paddingPx,
    required this.marginPx,
    required this.lineHeightPx,
  });

  final double paddingPx;
  final double marginPx;
  final double lineHeightPx;

  @override
  String toString() {
    return 'padding=$paddingPx margin=$marginPx lineHeight=$lineHeightPx';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pixel-scan: normal does not split short word across lines', (
    WidgetTester tester,
  ) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(const ui.Size(420, 260));
    addTearDown(() => binding.setSurfaceSize(null));

    const Key boundaryKey = ValueKey('boundary');

    await tester.pumpWidget(
      _wrapInTestApp(
        RepaintBoundary(
          key: boundaryKey,
          child: _wrapInInlineContainer(
            HtmlDiv(
              width: const FixedSize(260),
              height: const AutoSize(),
              border: HtmlBorder.all(width: const FixedBorderWidth(1)),
              padding: const HtmlPadding.all(HtmlLength.px(12)),
              lineHeight: HtmlLength.px(40),
              // default: normal
              children: const [
                Text('prefix ', style: TextStyle(fontSize: 12)),
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  children: [
                    Text(
                      'NESTED',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: _kRed,
                      ),
                    ),
                  ],
                ),
                Text(
                  ' suffix AaBbCc The quick brown fox jumps.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final _RgbaImage image = (await _captureRgba(
      tester,
      boundaryKey: boundaryKey,
    ))!;
    final (int minY, int maxY)? span = _PixelScan.verticalSpanForColor(
      image,
      target: _kRed,
      tolerance: 90,
      alphaMin: 10,
    );

    expect(span, isNotNull);
    final int height = span!.$2 - span.$1;

    // If the short word is split across lines, the red pixels will span at
    // least ~2 line heights. Keep a loose threshold for font rasterization.
    expect(height, lessThan(60));
  });

  testWidgets('pixel-scan: anywhere breaks long unbroken run across lines', (
    WidgetTester tester,
  ) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(const ui.Size(420, 260));
    addTearDown(() => binding.setSurfaceSize(null));

    const Key boundaryKey = ValueKey('boundary');

    const String longRun =
        'NESTEDNESTEDNESTEDNESTEDNESTEDNESTEDNESTEDNESTEDNESTEDNESTED';

    await tester.pumpWidget(
      _wrapInTestApp(
        RepaintBoundary(
          key: boundaryKey,
          child: _wrapInInlineContainer(
            HtmlDiv(
              width: const FixedSize(220),
              height: const AutoSize(),
              border: HtmlBorder.all(width: const FixedBorderWidth(1)),
              padding: const HtmlPadding.all(HtmlLength.px(12)),
              lineHeight: HtmlLength.px(40),
              overflowWrap: HtmlOverflowWrap.anywhere,
              children: const [
                Text(
                  longRun,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _kRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final _RgbaImage image = (await _captureRgba(
      tester,
      boundaryKey: boundaryKey,
    ))!;
    final (int minY, int maxY)? span = _PixelScan.verticalSpanForColor(
      image,
      target: _kRed,
      tolerance: 90,
      alphaMin: 10,
    );

    expect(span, isNotNull);
    final int height = span!.$2 - span.$1;

    // With anywhere enabled, the long unbroken run should wrap into multiple
    // lines, making the vertical span clearly exceed a single line.
    expect(height, greaterThan(60));
  });

  testWidgets(
    'pixel-scan: anywhere does not split short word just to fill remaining line',
    (WidgetTester tester) async {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const ui.Size(420, 260));
      addTearDown(() => binding.setSurfaceSize(null));

      const Key boundaryKey = ValueKey('boundary');

      await tester.pumpWidget(
        _wrapInTestApp(
          RepaintBoundary(
            key: boundaryKey,
            child: _wrapInInlineContainer(
              HtmlDiv(
                width: const FixedSize(260),
                height: const AutoSize(),
                border: HtmlBorder.all(width: const FixedBorderWidth(1)),
                padding: const HtmlPadding.all(HtmlLength.px(12)),
                lineHeight: HtmlLength.px(40),
                overflowWrap: HtmlOverflowWrap.anywhere,
                children: const [
                  // Make the first line almost full so only a tiny remaining
                  // space is left, which used to trigger per-character breaks.
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    width: FixedSize(210),
                    height: FixedSize(10),
                  ),
                  Text(
                    ' NESTED',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: _kRed,
                    ),
                  ),
                  Text(' suffix', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final _RgbaImage image = (await _captureRgba(
        tester,
        boundaryKey: boundaryKey,
      ))!;
      final (int minY, int maxY)? span = _PixelScan.verticalSpanForColor(
        image,
        target: _kRed,
        tolerance: 90,
        alphaMin: 10,
      );

      expect(span, isNotNull);
      final int height = span!.$2 - span.$1;

      // Even with anywhere enabled, short words should not be split across
      // lines merely to consume the remaining space on the previous line.
      expect(height, lessThan(60));
    },
  );

  testWidgets('pixel-scan: border/padding reduce content width and affect wrap', (
    WidgetTester tester,
  ) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(const ui.Size(420, 260));
    addTearDown(() => binding.setSurfaceSize(null));

    const Key boundaryKey = ValueKey('boundary');

    const String longRun =
        'NESTEDNESTEDNESTEDNESTEDNESTEDNESTEDNESTEDNESTEDNESTEDNESTED';

    await tester.pumpWidget(
      _wrapInTestApp(
        RepaintBoundary(
          key: boundaryKey,
          child: _wrapInInlineContainer(
            HtmlDiv(
              width: const FixedSize(260),
              height: const AutoSize(),
              // Larger padding makes contentWidth smaller for the same border-box.
              border: HtmlBorder.all(width: const FixedBorderWidth(4)),
              padding: const HtmlPadding.all(HtmlLength.px(24)),
              lineHeight: HtmlLength.px(40),
              overflowWrap: HtmlOverflowWrap.anywhere,
              children: const [
                Text(
                  longRun,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _kRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final _RgbaImage image = (await _captureRgba(
      tester,
      boundaryKey: boundaryKey,
    ))!;
    final (int minY, int maxY)? span = _PixelScan.verticalSpanForColor(
      image,
      target: _kRed,
      tolerance: 90,
      alphaMin: 10,
    );

    expect(span, isNotNull);
    final int height = span!.$2 - span.$1;

    // With anywhere enabled and reduced content width (due to border/padding),
    // wrapping should still happen.
    expect(height, greaterThan(60));
  });

  testWidgets(
    'pixel-scan: FitContent does not unexpectedly wrap short CJK runs (varying counts)',
    (WidgetTester tester) async {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const ui.Size(1600, 240));
      addTearDown(() => binding.setSurfaceSize(null));

      const Key boundaryKey = ValueKey('boundary');
      const double viewportWidth = 1200;

      // CJK can legally break between characters, so this regression test is
      // intentionally sensitive to sub-pixel shrink-to-fit underestimation.
      const List<int> counts = <int>[1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 16, 20];

      for (final int count in counts) {
        final String cjk = _repeatText('测', count);

        await tester.pumpWidget(
          _wrapInTestApp(
            RepaintBoundary(
              key: boundaryKey,
              child: _wrapInInlineContainer(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: viewportWidth),
                  child: HtmlDiv(
                    width: const FitContent(),
                    height: const AutoSize(),
                    boxSizing: HtmlBoxSizing.borderBox,
                    border: HtmlBorder.all(width: const FixedBorderWidth(1)),
                    padding: const HtmlPadding.all(HtmlLength.px(8)),
                    lineHeight: HtmlLength.px(40),
                    // default: normal
                    children: [
                      Text(
                        cjk,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: _kRed,
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

        final _RgbaImage image = (await _captureRgba(
          tester,
          boundaryKey: boundaryKey,
        ))!;
        final (int minY, int maxY)? span = _PixelScan.verticalSpanForColor(
          image,
          target: _kRed,
          tolerance: 90,
          alphaMin: 10,
        );

        expect(span, isNotNull, reason: 'count=$count');
        final int height = span!.$2 - span.$1;

        // Single line expected.
        expect(height, lessThan(60), reason: 'count=$count');
      }
    },
  );

  testWidgets(
    'pixel-scan: inline shrink-to-fit does not unexpectedly wrap CJK runs (varying counts)',
    (WidgetTester tester) async {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const ui.Size(1600, 240));
      addTearDown(() => binding.setSurfaceSize(null));

      const Key boundaryKey = ValueKey('boundary');
      const double viewportWidth = 1200;

      const List<int> counts = <int>[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        20,
      ];

      for (final int count in counts) {
        final String cjk = _repeatText('汉', count);

        await tester.pumpWidget(
          _wrapInTestApp(
            RepaintBoundary(
              key: boundaryKey,
              child: _wrapInInlineContainer(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: viewportWidth),
                  child: HtmlDiv(
                    width: const AutoSize(),
                    height: const AutoSize(),
                    boxSizing: HtmlBoxSizing.borderBox,
                    lineHeight: HtmlLength.px(40),
                    children: [
                      HtmlDiv(
                        display: HtmlDisplay.inline,
                        children: [
                          Text(
                            cjk,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: _kRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final _RgbaImage image = (await _captureRgba(
          tester,
          boundaryKey: boundaryKey,
        ))!;
        final (int minY, int maxY)? span = _PixelScan.verticalSpanForColor(
          image,
          target: _kRed,
          tolerance: 90,
          alphaMin: 10,
        );

        expect(span, isNotNull, reason: 'count=$count');
        final int height = span!.$2 - span.$1;

        expect(height, lessThan(60), reason: 'count=$count');
      }
    },
  );

  testWidgets(
    'pixel-scan: random mixed CJK/Latin/punct should not wrap when it fits (50 cases)',
    (WidgetTester tester) async {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const ui.Size(1600, 240));
      addTearDown(() => binding.setSurfaceSize(null));

      await _runRandomMixedNoWrapCases(tester, cases: 1000, seed: 1337);
    },
  );

  testWidgets(
    'pixel-scan: random mixed CJK/Latin/punct should not wrap when it fits (100 cases)',
    (WidgetTester tester) async {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const ui.Size(1600, 240));
      addTearDown(() => binding.setSurfaceSize(null));

      await _runRandomMixedNoWrapCases(tester, cases: 1000, seed: 20260105);
    },
  );

  testWidgets(
    'pixel-scan: random mixed cases stay single-line across padding/margin/lineHeight variants',
    (WidgetTester tester) async {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const ui.Size(1600, 280));
      addTearDown(() => binding.setSurfaceSize(null));

      const double viewportMaxWidth = 1200;
      const double borderWidthPx = 1;

      const List<_BoxModelCase> variants = <_BoxModelCase>[
        _BoxModelCase(paddingPx: 0, marginPx: 0, lineHeightPx: 32),
        _BoxModelCase(paddingPx: 8, marginPx: 0, lineHeightPx: 40),
        _BoxModelCase(paddingPx: 24, marginPx: 0, lineHeightPx: 56),
        _BoxModelCase(paddingPx: 8, marginPx: 12, lineHeightPx: 40),
        _BoxModelCase(paddingPx: 24, marginPx: 12, lineHeightPx: 56),
        _BoxModelCase(paddingPx: 8, marginPx: 40, lineHeightPx: 40),
      ];

      for (int i = 0; i < variants.length; i++) {
        final _BoxModelCase v = variants[i];
        await _runRandomMixedNoWrapCasesWithBoxModel(
          tester,
          cases: 20,
          seed: 9000 + i,
          viewportMaxWidth: viewportMaxWidth,
          borderWidthPx: borderWidthPx,
          paddingPx: v.paddingPx,
          marginPx: v.marginPx,
          lineHeightPx: v.lineHeightPx,
          boxSizing: HtmlBoxSizing.contentBox,
        );
      }
    },
  );

  testWidgets(
    'pixel-scan: border-box random mixed cases stay single-line across padding/margin/lineHeight variants',
    (WidgetTester tester) async {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const ui.Size(1600, 280));
      addTearDown(() => binding.setSurfaceSize(null));

      const double viewportMaxWidth = 1200;
      const double borderWidthPx = 1;

      const List<_BoxModelCase> variants = <_BoxModelCase>[
        _BoxModelCase(paddingPx: 0, marginPx: 0, lineHeightPx: 32),
        _BoxModelCase(paddingPx: 8, marginPx: 0, lineHeightPx: 40),
        _BoxModelCase(paddingPx: 24, marginPx: 0, lineHeightPx: 56),
        _BoxModelCase(paddingPx: 8, marginPx: 12, lineHeightPx: 40),
        _BoxModelCase(paddingPx: 24, marginPx: 12, lineHeightPx: 56),
        _BoxModelCase(paddingPx: 8, marginPx: 40, lineHeightPx: 40),
      ];

      for (int i = 0; i < variants.length; i++) {
        final _BoxModelCase v = variants[i];
        await _runRandomMixedNoWrapCasesWithBoxModel(
          tester,
          cases: 20,
          seed: 12000 + i,
          viewportMaxWidth: viewportMaxWidth,
          borderWidthPx: borderWidthPx,
          paddingPx: v.paddingPx,
          marginPx: v.marginPx,
          lineHeightPx: v.lineHeightPx,
          boxSizing: HtmlBoxSizing.borderBox,
        );
      }
    },
  );
}
