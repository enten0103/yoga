import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

void main() {
  testWidgets('width: FitContent does not wrap h3 when space is available', (
    WidgetTester tester,
  ) async {
    const TextStyle h3Style = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );

    final TextPainter tp = TextPainter(
      text: const TextSpan(text: 'C O N T E N T S', style: h3Style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    final TextPainter tpLast = TextPainter(
      text: const TextSpan(text: '当春天来临，你会——'),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    // Give enough space for the max-content width of the widest content.
    final double viewportWidth = math.max(tp.width, tpLast.width) + 200;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: viewportWidth,
            child: HtmlDiv(
              padding: const HtmlPadding.all(HtmlLength.px(8)),
              children: [
                HtmlDiv(
                  key: const ValueKey('fit'),
                  width: const FitContent(),
                  margin: const HtmlMargin.horizontalAuto(
                    top: HtmlLength.px(0),
                    bottom: HtmlLength.px(0),
                  ),
                  children: [
                    HtmlDiv(
                      margin: const HtmlMargin.only(
                        top: HtmlLength.px(16),
                        bottom: HtmlLength.px(16),
                      ),
                      textAlign: HtmlTextAlign.center,
                      children: const [
                        // Mirror the XHTML: <h3>C O N T E N T S</h3>
                        HtmlText('C O N T E N T S', style: h3Style),
                      ],
                    ),
                    HtmlDiv(
                      children: [
                        HtmlDiv(
                          children: [
                            HtmlDiv(
                              display: HtmlDisplay.flex,
                              alignItems: HtmlAlignItems.flexStart,
                              children: [
                                HtmlDiv(
                                  children: const [
                                    HtmlDiv(
                                      margin: HtmlMargin.only(
                                        bottom: HtmlLength.px(12),
                                      ),
                                      children: [HtmlText('1')],
                                    ),
                                    HtmlDiv(
                                      margin: HtmlMargin.only(
                                        bottom: HtmlLength.px(12),
                                      ),
                                      children: [HtmlText('2')],
                                    ),
                                    HtmlDiv(
                                      margin: HtmlMargin.only(
                                        bottom: HtmlLength.px(12),
                                      ),
                                      children: [HtmlText('3')],
                                    ),
                                    HtmlDiv(
                                      margin: HtmlMargin.only(
                                        bottom: HtmlLength.px(12),
                                      ),
                                      children: [HtmlText('4')],
                                    ),
                                    HtmlDiv(
                                      margin: HtmlMargin.only(
                                        bottom: HtmlLength.px(12),
                                      ),
                                      children: [HtmlText('5')],
                                    ),
                                    HtmlDiv(
                                      margin: HtmlMargin.only(
                                        bottom: HtmlLength.px(12),
                                      ),
                                      children: [HtmlText('6')],
                                    ),
                                    HtmlDiv(children: [HtmlText('7')]),
                                  ],
                                ),
                                HtmlDiv(
                                  margin: const HtmlMargin.only(
                                    left: HtmlLength.px(24),
                                  ),
                                  children: const [
                                    HtmlDiv(
                                      margin: HtmlMargin.only(
                                        bottom: HtmlLength.px(12),
                                      ),
                                      children: [
                                        HtmlText('Menthol Light\u7684'),
                                        HtmlText(
                                          '\u7ea2',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        HtmlText('\u8776'),
                                      ],
                                    ),
                                    HtmlDiv(
                                      children: [
                                        HtmlText('\u5f53'),
                                        HtmlText(
                                          '\u6625',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        HtmlText('天来临，你会——'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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

    final Finder headingFinder = find.byWidgetPredicate(
      (Widget w) => w is HtmlText && w.data == 'C O N T E N T S',
    );
    expect(headingFinder, findsOneWidget);

    final RenderHtmlText heading = tester.renderObject<RenderHtmlText>(
      headingFinder,
    );

    // Regression: in a wide enough containing block, fit-content should
    // expand to max-content width, so the heading must not wrap.
    expect(heading.debugLineCount, equals(1));

    // And the fit-content box should be at least as wide as the heading's
    // max intrinsic width (within a small epsilon).
    final Size fitSize = tester.getSize(find.byKey(const ValueKey('fit')));
    final double headingMax = heading.getMaxIntrinsicWidth(double.infinity);
    expect(fitSize.width + 0.5, greaterThanOrEqualTo(headingMax));

    // The last (longest) item must also stay on a single line when the
    // containing block is wide enough.
    final Finder lastLineFinder = find.byWidgetPredicate(
      (Widget w) => w is HtmlText && w.data == '天来临，你会——',
    );
    expect(lastLineFinder, findsOneWidget);
    final RenderHtmlText lastLine = tester.renderObject<RenderHtmlText>(
      lastLineFinder,
    );
    expect(lastLine.debugLineCount, equals(1));
  });

  testWidgets(
    'inline span pieces stay on the same line when width is sufficient',
    (WidgetTester tester) async {
      const double viewportWidth = 800;

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: viewportWidth,
              child: HtmlDiv(
                key: ValueKey('root'),
                children: [
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    children: [
                      HtmlText('Menthol Light\u7684'),
                      HtmlText('\u7ea2', style: TextStyle(color: Colors.red)),
                      HtmlText('\u8776'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final RenderHtmlText t1 = tester.renderObject<RenderHtmlText>(
        find.byWidgetPredicate(
          (Widget w) => w is HtmlText && w.data == 'Menthol Light\u7684',
        ),
      );
      final RenderHtmlText t2 = tester.renderObject<RenderHtmlText>(
        find.byWidgetPredicate(
          (Widget w) => w is HtmlText && w.data == '\u7ea2',
        ),
      );
      final RenderHtmlText t3 = tester.renderObject<RenderHtmlText>(
        find.byWidgetPredicate(
          (Widget w) => w is HtmlText && w.data == '\u8776',
        ),
      );

      final Offset o1 = (t1.parentData! as HtmlDivParentData).offset;
      final Offset o2 = (t2.parentData! as HtmlDivParentData).offset;
      final Offset o3 = (t3.parentData! as HtmlDivParentData).offset;

      // All three runs should be on the same formatted line.
      expect((o1.dy - o2.dy).abs(), lessThan(0.5));
      expect((o1.dy - o3.dy).abs(), lessThan(0.5));
    },
  );

  testWidgets('atomic inline wrapper keeps 会—— unbroken', (
    WidgetTester tester,
  ) async {
    const TextStyle style = TextStyle(fontSize: 16);

    // Force wrapping so the trailing punctuation group may move to a new line.
    const double width = 120;

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: width,
          child: HtmlDiv(
            width: FixedSize(width),
            children: [
              HtmlDiv(
                children: [
                  HtmlText('天来临，你', style: style),
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    width: MaxContent(),
                    children: [HtmlText('会——', style: style)],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final RenderHtmlText group = tester.renderObject<RenderHtmlText>(
      find.byWidgetPredicate((Widget w) => w is HtmlText && w.data == '会——'),
    );
    expect(group.debugLineCount, equals(1));
  });

  testWidgets('block maxIntrinsicWidth matches paragraph shaping', (
    WidgetTester tester,
  ) async {
    const TextStyle style = TextStyle(fontSize: 16);

    // Build a block with multiple inline segments, including an atomic inline
    // wrapper (placeholder) at the end.
    const HtmlDiv block = HtmlDiv(
      children: [
        HtmlText('当春天来临，', style: style),
        HtmlText('你', style: style),
        HtmlDiv(
          display: HtmlDisplay.inline,
          width: MaxContent(),
          children: [HtmlText('会——', style: style)],
        ),
      ],
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: block),
      ),
    );

    final RenderHtmlDiv ro = tester.renderObject<RenderHtmlDiv>(
      find.byWidget(block),
    );

    final double intrinsic = ro.getMaxIntrinsicWidth(double.infinity);
    final TextPainter tp = TextPainter(
      text: const TextSpan(text: '当春天来临，你会——', style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    // Intrinsic must not be smaller than the paragraph's shaped width,
    // otherwise shrink-to-fit containers can become too narrow and force wraps.
    expect(intrinsic + 0.01, greaterThanOrEqualTo(tp.width));
  });

  testWidgets('fit-content + flex keeps 会—— on same line', (
    WidgetTester tester,
  ) async {
    // This matches the reported screenshot: when the trailing group is short
    // (会——), it used to wrap onto the next line, but adding one more
    // character would avoid the wrap. This test guards against sub-pixel
    // shrink-to-fit width underestimation.
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: FitContent(),
            children: [
              HtmlDiv(
                display: HtmlDisplay.flex,
                children: [
                  HtmlDiv(children: [HtmlText('7')]),
                  HtmlDiv(
                    margin: HtmlMargin.only(left: HtmlLength.px(24)),
                    children: [
                      HtmlDiv(
                        children: [
                          HtmlText('当春天来临，你'),
                          HtmlDiv(
                            display: HtmlDisplay.inline,
                            width: MaxContent(),
                            children: [HtmlText('会——')],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final RenderHtmlText prefix = tester.renderObject<RenderHtmlText>(
      find.byWidgetPredicate(
        (Widget w) => w is HtmlText && w.data == '当春天来临，你',
      ),
    );
    final RenderHtmlText tail = tester.renderObject<RenderHtmlText>(
      find.byWidgetPredicate((Widget w) => w is HtmlText && w.data == '会——'),
    );

    final Offset prefixOffset =
        (prefix.parentData! as HtmlDivParentData).offset;
    final Offset tailOffset = (tail.parentData! as HtmlDivParentData).offset;

    // If it wrapped, tail would be on the next line (larger dy).
    expect((tailOffset.dy - prefixOffset.dy).abs(), lessThan(1.0));
  });
}
