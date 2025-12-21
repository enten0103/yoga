import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

class _IntrinsicHeightRecorder extends SingleChildRenderObjectWidget {
  const _IntrinsicHeightRecorder({super.key, super.child});

  @override
  _RenderIntrinsicHeightRecorder createRenderObject(BuildContext context) {
    return _RenderIntrinsicHeightRecorder();
  }
}

class _RenderIntrinsicHeightRecorder extends RenderProxyBox {
  double? recordedMaxIntrinsicHeight;

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      recordedMaxIntrinsicHeight = 0;
      return;
    }

    child!.layout(constraints, parentUsesSize: true);
    size = child!.size;

    // Record intrinsics during layout so Flutter's debug asserts allow
    // baseline queries within intrinsic computations.
    recordedMaxIntrinsicHeight = child!.getMaxIntrinsicHeight(size.width);
  }
}

void main() {
  test('HtmlLength.multiplier scales reference in resolvePx', () {
    expect(const HtmlLength.multiplier(1.3).resolvePx(reference: 10), 13);
    expect(const HtmlLength.multiplier(0).resolvePx(reference: 10), 0);
  });

  testWidgets('lineHeight supports unitless multipliers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('root'),
            width: const FixedSize(200),
            height: const AutoSize(),
            lineHeight: const HtmlLength.multiplier(2),
            border: HtmlBorder.all(width: const FixedBorderWidth(0)),
            children: const [Text('x', style: TextStyle(fontSize: 10))],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size rootSize = tester.getSize(find.byKey(const ValueKey('root')));
    // CSS-like: multiplier resolves against font-size.
    // fontSize=10, multiplier(2) => line-height = 20.
    expect(rootSize.height, equals(20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('lineHeight multiplier applies per wrapped line', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('root'),
            width: const FixedSize(160),
            height: const AutoSize(),
            lineHeight: const HtmlLength.multiplier(2),
            border: HtmlBorder.all(width: const FixedBorderWidth(0)),
            children: const [
              // Each inline box is 90px wide; only one fits per 160px line.
              HtmlDiv(
                display: HtmlDisplay.inline,
                width: FixedSize(90),
                children: [Text('x', style: TextStyle(fontSize: 10))],
              ),
              HtmlDiv(
                display: HtmlDisplay.inline,
                width: FixedSize(90),
                children: [Text('x', style: TextStyle(fontSize: 10))],
              ),
              HtmlDiv(
                display: HtmlDisplay.inline,
                width: FixedSize(90),
                children: [Text('x', style: TextStyle(fontSize: 10))],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size rootSize = tester.getSize(find.byKey(const ValueKey('root')));
    // fontSize=10, multiplier(2) => per-line line-height = 20.
    // 3 lines => 60.
    expect(rootSize.height, equals(60));
    expect(tester.takeException(), isNull);
  });

  testWidgets('lineHeight percent matches multiplier semantics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('root'),
            width: const FixedSize(200),
            height: const AutoSize(),
            lineHeight: const HtmlLength.percent(200),
            border: HtmlBorder.all(width: const FixedBorderWidth(0)),
            children: const [Text('x', style: TextStyle(fontSize: 10))],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size rootSize = tester.getSize(find.byKey(const ValueKey('root')));
    // fontSize=10, 200% => line-height = 20.
    expect(rootSize.height, equals(20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('lineHeight fixed px overrides natural line height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('root'),
            width: const FixedSize(200),
            height: const AutoSize(),
            lineHeight: const HtmlLength.px(50),
            border: HtmlBorder.all(width: const FixedBorderWidth(0)),
            children: const [Text('x', style: TextStyle(fontSize: 10))],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size rootSize = tester.getSize(find.byKey(const ValueKey('root')));
    expect(rootSize.height, equals(50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested lineHeight does not shrink line boxes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('root'),
            width: const FixedSize(200),
            height: const AutoSize(),
            // Smaller than the natural height of the inline child.
            lineHeight: const HtmlLength.px(24),
            border: HtmlBorder.all(width: const FixedBorderWidth(0)),
            children: const [
              HtmlDiv(
                display: HtmlDisplay.inline,
                width: FixedSize(50),
                height: FixedSize(30),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size rootSize = tester.getSize(find.byKey(const ValueKey('root')));
    // With CSS-like strut/baseline allocation, an explicit line-height may add
    // descent even for a replaced-like inline box whose baseline is its bottom.
    // The key invariant is: line boxes never shrink below the natural box.
    expect(rootSize.height, greaterThanOrEqualTo(30));
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested larger child lineHeight determines final height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('root'),
            width: const FixedSize(200),
            height: const AutoSize(),
            // Parent minimum smaller than child's computed line height.
            lineHeight: const HtmlLength.px(24),
            border: HtmlBorder.all(width: const FixedBorderWidth(0)),
            children: const [
              HtmlDiv(
                display: HtmlDisplay.inline,
                // Child creates its own line boxes and sets a larger minimum.
                lineHeight: HtmlLength.px(40),
                children: [
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    width: FixedSize(50),
                    height: FixedSize(20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size rootSize = tester.getSize(find.byKey(const ValueKey('root')));
    // Parent may still contribute strut descent, but must not be smaller than
    // the child's computed line box height.
    expect(rootSize.height, greaterThanOrEqualTo(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested inline HtmlDiv uses last line baseline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('root'),
            width: const FixedSize(420),
            height: const AutoSize(),
            lineHeight: const HtmlLength.px(24),
            border: HtmlBorder.all(width: const FixedBorderWidth(0)),
            children: const [
              Text(
                'prefix ',
                key: ValueKey('prefix'),
                style: TextStyle(fontSize: 12),
              ),
              HtmlDiv(
                display: HtmlDisplay.inline,
                children: [
                  Text(
                    'NESTED',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Text(
                ' suffix',
                key: ValueKey('suffix'),
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final double rootBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('root')))
        .dy;
    final double prefixBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('prefix')))
        .dy;
    final double suffixBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('suffix')))
        .dy;

    // The small text should not be pushed onto the bottom edge of the line box.
    expect(rootBottom - prefixBottom, greaterThan(0.5));
    expect(rootBottom - suffixBottom, greaterThan(0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline children flow horizontally and wrap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(200),
            height: const AutoSize(),
            border: HtmlBorder.all(width: const FixedBorderWidth(0)),
            children: const [
              HtmlDiv(
                key: ValueKey('a'),
                display: HtmlDisplay.inline,
                width: FixedSize(80),
                height: FixedSize(20),
              ),
              HtmlDiv(
                key: ValueKey('b'),
                display: HtmlDisplay.inline,
                width: FixedSize(80),
                height: FixedSize(20),
              ),
              HtmlDiv(
                key: ValueKey('c'),
                display: HtmlDisplay.inline,
                width: FixedSize(80),
                height: FixedSize(20),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset a = tester.getTopLeft(find.byKey(const ValueKey('a')));
    final Offset b = tester.getTopLeft(find.byKey(const ValueKey('b')));
    final Offset c = tester.getTopLeft(find.byKey(const ValueKey('c')));

    expect(b.dy, equals(a.dy));
    expect(b.dx, greaterThan(a.dx));

    expect(c.dy, greaterThan(a.dy));
    expect(c.dx, equals(a.dx));

    expect(tester.takeException(), isNull);
  });

  testWidgets('block child breaks inline run', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(200),
            height: const AutoSize(),
            children: const [
              HtmlDiv(
                key: ValueKey('a'),
                display: HtmlDisplay.inline,
                width: FixedSize(120),
                height: FixedSize(20),
              ),
              HtmlDiv(
                key: ValueKey('block'),
                display: HtmlDisplay.block,
                width: FixedSize(180),
                height: FixedSize(30),
              ),
              HtmlDiv(
                key: ValueKey('b'),
                display: HtmlDisplay.inline,
                width: FixedSize(120),
                height: FixedSize(20),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset a = tester.getTopLeft(find.byKey(const ValueKey('a')));
    final Offset block = tester.getTopLeft(find.byKey(const ValueKey('block')));
    final Offset b = tester.getTopLeft(find.byKey(const ValueKey('b')));

    expect(block.dy, greaterThan(a.dy));
    expect(b.dy, greaterThan(block.dy));

    expect(tester.takeException(), isNull);
  });

  testWidgets('display=inline shrink-to-fit when auto width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(300),
            height: const AutoSize(),
            children: const [
              HtmlDiv(
                key: ValueKey('inline'),
                display: HtmlDisplay.inline,
                width: AutoSize(),
                height: AutoSize(),
                children: [
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    width: FixedSize(60),
                    height: FixedSize(20),
                  ),
                  HtmlDiv(
                    display: HtmlDisplay.inline,
                    width: FixedSize(50),
                    height: FixedSize(20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final RenderBox inline = tester.renderObject(
      find.byKey(const ValueKey('inline')),
    );
    expect(inline.size.width, equals(110));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline baseline aligns bottoms by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(240),
            height: const AutoSize(),
            children: const [
              HtmlDiv(
                key: ValueKey('tall'),
                display: HtmlDisplay.inline,
                width: FixedSize(80),
                height: FixedSize(40),
              ),
              HtmlDiv(
                key: ValueKey('short'),
                display: HtmlDisplay.inline,
                width: FixedSize(80),
                height: FixedSize(16),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset tallBottom = tester.getBottomLeft(
      find.byKey(const ValueKey('tall')),
    );
    final Offset shortBottom = tester.getBottomLeft(
      find.byKey(const ValueKey('short')),
    );

    expect(shortBottom.dy, equals(tallBottom.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline baseline aligns even if later child is taller', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(240),
            height: const AutoSize(),
            children: const [
              HtmlDiv(
                key: ValueKey('shortFirst'),
                display: HtmlDisplay.inline,
                width: FixedSize(80),
                height: FixedSize(16),
              ),
              HtmlDiv(
                key: ValueKey('tallSecond'),
                display: HtmlDisplay.inline,
                width: FixedSize(80),
                height: FixedSize(40),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset shortBottom = tester.getBottomLeft(
      find.byKey(const ValueKey('shortFirst')),
    );
    final Offset tallBottom = tester.getBottomLeft(
      find.byKey(const ValueKey('tallSecond')),
    );

    expect(shortBottom.dy, equals(tallBottom.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('text-align center affects inline line start', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('parent'),
            width: const FixedSize(200),
            height: const AutoSize(),
            textAlign: HtmlTextAlign.center,
            children: const [
              HtmlDiv(
                key: ValueKey('a'),
                display: HtmlDisplay.inline,
                width: FixedSize(50),
                height: FixedSize(20),
              ),
              HtmlDiv(
                key: ValueKey('b'),
                display: HtmlDisplay.inline,
                width: FixedSize(50),
                height: FixedSize(20),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset parentTop = tester.getTopLeft(
      find.byKey(const ValueKey('parent')),
    );
    final Offset aTop = tester.getTopLeft(find.byKey(const ValueKey('a')));
    final double localAx = aTop.dx - parentTop.dx;
    // Remaining space is 100, centered -> start shift 50.
    expect(localAx, equals(50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('line-height enforces minimum line box height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('parent'),
            width: const FixedSize(200),
            height: const AutoSize(),
            lineHeight: const HtmlLength.px(60),
            children: const [
              HtmlDiv(
                display: HtmlDisplay.inline,
                width: FixedSize(50),
                height: FixedSize(20),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final RenderBox parent = tester.renderObject(
      find.byKey(const ValueKey('parent')),
    );
    expect(parent.size.height, equals(60));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'inline maxIntrinsicHeight matches layout height when wrapping (percent line-height)',
    (WidgetTester tester) async {
      // Regression test for `_inlineIntrinsicHeight`: when a child wraps to the
      // next line (e.g. due to text-indent on the first line), the intrinsic
      // height computation must re-evaluate the child's height under the new
      // maxWidth, otherwise line-height (percent) can diverge from real layout.
      const Key subjectKey = ValueKey('subject');
      const Key recorderKey = ValueKey('recorder');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 200,
              child: _IntrinsicHeightRecorder(
                key: recorderKey,
                child: HtmlDiv(
                  key: subjectKey,
                  display: HtmlDisplay.inline,
                  width: const FixedSize(200),
                  height: const AutoSize(),
                  textIndent: const HtmlLength.px(80),
                  lineHeight: const HtmlLength.percent(200),
                  children: const [
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      width: FixedSize(119),
                      height: FixedSize(10),
                    ),
                    Text(
                      key: ValueKey('text'),
                      'word word word word word',
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final RenderBox subject = tester.renderObject(find.byKey(subjectKey));
      final RenderBox textBox = tester.renderObject(
        find.byKey(const ValueKey('text')),
      );

      // Ensure the text is sensitive to the width (wraps differently).
      final double textH120 = textBox.getMaxIntrinsicHeight(120);
      final double textH200 = textBox.getMaxIntrinsicHeight(200);
      expect(textH120, greaterThan(textH200));

      final _RenderIntrinsicHeightRecorder recorder = tester.renderObject(
        find.byKey(recorderKey),
      );

      expect(recorder.recordedMaxIntrinsicHeight, isNotNull);
      expect(
        (recorder.recordedMaxIntrinsicHeight! - subject.size.height).abs(),
        lessThan(0.01),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('text-indent shifts first inline line start (px)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('parentIndentPx'),
            width: const FixedSize(200),
            height: const AutoSize(),
            textIndent: const HtmlLength.px(40),
            children: const [
              HtmlDiv(
                key: ValueKey('a'),
                display: HtmlDisplay.inline,
                width: FixedSize(50),
                height: FixedSize(20),
              ),
              HtmlDiv(
                key: ValueKey('b'),
                display: HtmlDisplay.inline,
                width: FixedSize(50),
                height: FixedSize(20),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset parentTop = tester.getTopLeft(
      find.byKey(const ValueKey('parentIndentPx')),
    );
    final Offset aTop = tester.getTopLeft(find.byKey(const ValueKey('a')));
    expect(aTop.dx - parentTop.dx, equals(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('text-indent only applies to the first formatted line', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: const ValueKey('parentIndentWrap'),
            width: const FixedSize(100),
            height: const AutoSize(),
            textIndent: const HtmlLength.px(40),
            children: const [
              HtmlDiv(
                key: ValueKey('first'),
                display: HtmlDisplay.inline,
                width: FixedSize(60),
                height: FixedSize(20),
              ),
              HtmlDiv(
                key: ValueKey('second'),
                display: HtmlDisplay.inline,
                width: FixedSize(60),
                height: FixedSize(20),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset parentTop = tester.getTopLeft(
      find.byKey(const ValueKey('parentIndentWrap')),
    );
    final Offset firstTop = tester.getTopLeft(
      find.byKey(const ValueKey('first')),
    );
    final Offset secondTop = tester.getTopLeft(
      find.byKey(const ValueKey('second')),
    );

    expect(firstTop.dx - parentTop.dx, equals(40));
    expect(secondTop.dy, greaterThan(firstTop.dy));
    expect(secondTop.dx - parentTop.dx, equals(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('text-indent supports percent and interacts with text-align', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 200,
            child: HtmlDiv(
              key: const ValueKey('parentIndentPercent'),
              width: const FixedSize(200),
              height: const AutoSize(),
              textIndent: const HtmlLength.percent(10),
              textAlign: HtmlTextAlign.center,
              children: const [
                HtmlDiv(
                  key: ValueKey('a'),
                  display: HtmlDisplay.inline,
                  width: FixedSize(50),
                  height: FixedSize(20),
                ),
                HtmlDiv(
                  key: ValueKey('b'),
                  display: HtmlDisplay.inline,
                  width: FixedSize(50),
                  height: FixedSize(20),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset parentTop = tester.getTopLeft(
      find.byKey(const ValueKey('parentIndentPercent')),
    );
    final Offset aTop = tester.getTopLeft(find.byKey(const ValueKey('a')));

    // width=200, indent=10% => 20. Remaining=180, used=100, extra=80, centered shift=40.
    expect(aTop.dx - parentTop.dx, equals(60));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'text-indent percent resolves against containing block width (not reduced by padding)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: HtmlDiv(
              width: const FixedSize(200),
              height: const AutoSize(),
              children: const [
                HtmlDiv(
                  key: ValueKey('subjectIndentPercentPadding'),
                  width: FixedSize(200),
                  height: AutoSize(),
                  boxSizing: HtmlBoxSizing.borderBox,
                  padding: HtmlPadding.symmetric(horizontal: HtmlLength.px(20)),
                  textIndent: HtmlLength.percent(10),
                  children: [
                    HtmlDiv(
                      key: ValueKey('a'),
                      display: HtmlDisplay.inline,
                      width: FixedSize(50),
                      height: FixedSize(20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Offset subjectTop = tester.getTopLeft(
        find.byKey(const ValueKey('subjectIndentPercentPadding')),
      );
      final Offset aTop = tester.getTopLeft(find.byKey(const ValueKey('a')));

      // containing block width = 200, indent = 10% => 20.
      // plus padding-left=20 => local start should be 40.
      expect(aTop.dx - subjectTop.dx, equals(40));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('text-indent percent can cause wrapping on the first line only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 100,
            child: HtmlDiv(
              key: ValueKey('parentIndentPercentWrap'),
              width: FixedSize(100),
              height: AutoSize(),
              textIndent: HtmlLength.percent(50),
              children: [
                HtmlDiv(
                  key: ValueKey('first'),
                  display: HtmlDisplay.inline,
                  width: FixedSize(40),
                  height: FixedSize(20),
                ),
                HtmlDiv(
                  key: ValueKey('second'),
                  display: HtmlDisplay.inline,
                  width: FixedSize(40),
                  height: FixedSize(20),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset parentTop = tester.getTopLeft(
      find.byKey(const ValueKey('parentIndentPercentWrap')),
    );
    final Offset firstTop = tester.getTopLeft(
      find.byKey(const ValueKey('first')),
    );
    final Offset secondTop = tester.getTopLeft(
      find.byKey(const ValueKey('second')),
    );

    // width=100, indent=50% => 50.
    expect(firstTop.dx - parentTop.dx, equals(50));
    // Second wraps and should not be indented.
    expect(secondTop.dy, greaterThan(firstTop.dy));
    expect(secondTop.dx - parentTop.dx, equals(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'text-indent percent interacts with padding and wrapping (border-box)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 200,
              child: HtmlDiv(
                key: ValueKey('parentIndentPercentPaddingWrap'),
                width: FixedSize(200),
                height: AutoSize(),
                boxSizing: HtmlBoxSizing.borderBox,
                padding: HtmlPadding.symmetric(horizontal: HtmlLength.px(20)),
                textIndent: HtmlLength.percent(50),
                children: [
                  HtmlDiv(
                    key: ValueKey('first'),
                    display: HtmlDisplay.inline,
                    width: FixedSize(50),
                    height: FixedSize(20),
                  ),
                  HtmlDiv(
                    key: ValueKey('second'),
                    display: HtmlDisplay.inline,
                    width: FixedSize(50),
                    height: FixedSize(20),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Offset parentTop = tester.getTopLeft(
        find.byKey(const ValueKey('parentIndentPercentPaddingWrap')),
      );
      final Offset firstTop = tester.getTopLeft(
        find.byKey(const ValueKey('first')),
      );
      final Offset secondTop = tester.getTopLeft(
        find.byKey(const ValueKey('second')),
      );

      // containing block width=200, indent=50% => 100.
      // plus padding-left=20 => first local start should be 120.
      expect(firstTop.dx - parentTop.dx, equals(120));
      // Second wraps and should start at padding-left.
      expect(secondTop.dy, greaterThan(firstTop.dy));
      expect(secondTop.dx - parentTop.dx, equals(20));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('text-indent supports negative values (px)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 200,
            child: HtmlDiv(
              key: ValueKey('parentIndentNegative'),
              width: FixedSize(200),
              height: AutoSize(),
              textIndent: HtmlLength.px(-20),
              children: [
                HtmlDiv(
                  key: ValueKey('a'),
                  display: HtmlDisplay.inline,
                  width: FixedSize(50),
                  height: FixedSize(20),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset parentTop = tester.getTopLeft(
      find.byKey(const ValueKey('parentIndentNegative')),
    );
    final Offset aTop = tester.getTopLeft(find.byKey(const ValueKey('a')));
    expect(aTop.dx - parentTop.dx, equals(-20));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'inline maxIntrinsicHeight matches layout height when wrapping (percent text-indent + padding)',
    (WidgetTester tester) async {
      const Key subjectKey = ValueKey('subjectIndentPercentPaddingIntrinsic');
      const Key recorderKey = ValueKey('recorderIndentPercentPaddingIntrinsic');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 200,
              child: _IntrinsicHeightRecorder(
                key: recorderKey,
                child: HtmlDiv(
                  key: subjectKey,
                  display: HtmlDisplay.inline,
                  width: const FixedSize(200),
                  height: const AutoSize(),
                  boxSizing: HtmlBoxSizing.borderBox,
                  padding: const HtmlPadding.symmetric(
                    horizontal: HtmlLength.px(20),
                  ),
                  textIndent: const HtmlLength.percent(50),
                  children: const [
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      width: FixedSize(50),
                      height: FixedSize(10),
                    ),
                    Text(
                      key: ValueKey('text'),
                      'word word word word word',
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final RenderBox subject = tester.renderObject(find.byKey(subjectKey));
      final _RenderIntrinsicHeightRecorder recorder = tester.renderObject(
        find.byKey(recorderKey),
      );

      expect(recorder.recordedMaxIntrinsicHeight, isNotNull);
      expect(
        (recorder.recordedMaxIntrinsicHeight! - subject.size.height).abs(),
        lessThan(0.01),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('FitContent inline clamps to available width and wraps inside', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(200),
            height: const AutoSize(),
            children: const [
              HtmlDiv(
                key: ValueKey('fitInline'),
                display: HtmlDisplay.inline,
                width: FitContent(),
                height: AutoSize(),
                children: [
                  HtmlDiv(
                    key: ValueKey('inner1'),
                    display: HtmlDisplay.inline,
                    width: FixedSize(150),
                    height: FixedSize(20),
                  ),
                  HtmlDiv(
                    key: ValueKey('inner2'),
                    display: HtmlDisplay.inline,
                    width: FixedSize(150),
                    height: FixedSize(20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final RenderBox fitInline = tester.renderObject(
      find.byKey(const ValueKey('fitInline')),
    );
    // min-content=150, max-content=300, available=200 => fit-content=200.
    expect(fitInline.size.width, equals(200));

    final Offset inner1Top = tester.getTopLeft(
      find.byKey(const ValueKey('inner1')),
    );
    final Offset inner2Top = tester.getTopLeft(
      find.byKey(const ValueKey('inner2')),
    );
    expect(inner2Top.dy, greaterThan(inner1Top.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested inline shrink-to-fit propagates widths', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(300),
            height: const AutoSize(),
            children: const [
              HtmlDiv(
                key: ValueKey('outer'),
                display: HtmlDisplay.inline,
                width: AutoSize(),
                height: AutoSize(),
                children: [
                  HtmlDiv(
                    key: ValueKey('inner'),
                    display: HtmlDisplay.inline,
                    width: AutoSize(),
                    height: AutoSize(),
                    children: [
                      HtmlDiv(
                        display: HtmlDisplay.inline,
                        width: FixedSize(60),
                        height: FixedSize(20),
                      ),
                      HtmlDiv(
                        display: HtmlDisplay.inline,
                        width: FixedSize(50),
                        height: FixedSize(20),
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

    final RenderBox outer = tester.renderObject(
      find.byKey(const ValueKey('outer')),
    );
    final RenderBox inner = tester.renderObject(
      find.byKey(const ValueKey('inner')),
    );
    expect(inner.size.width, equals(110));
    expect(outer.size.width, equals(110));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline element can layout block children inside', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(300),
            height: const AutoSize(),
            children: const [
              HtmlDiv(
                key: ValueKey('outerInline'),
                display: HtmlDisplay.inline,
                width: AutoSize(),
                height: AutoSize(),
                children: [
                  HtmlDiv(
                    key: ValueKey('i1'),
                    display: HtmlDisplay.inline,
                    width: FixedSize(80),
                    height: FixedSize(20),
                  ),
                  HtmlDiv(
                    key: ValueKey('blk'),
                    display: HtmlDisplay.block,
                    width: FixedSize(150),
                    height: FixedSize(30),
                  ),
                  HtmlDiv(
                    key: ValueKey('i2'),
                    display: HtmlDisplay.inline,
                    width: FixedSize(80),
                    height: FixedSize(20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset i1Top = tester.getTopLeft(find.byKey(const ValueKey('i1')));
    final Offset blkTop = tester.getTopLeft(find.byKey(const ValueKey('blk')));
    final Offset i2Top = tester.getTopLeft(find.byKey(const ValueKey('i2')));

    expect(blkTop.dy, greaterThan(i1Top.dy));
    expect(i2Top.dy, greaterThan(blkTop.dy));

    final RenderBox outer = tester.renderObject(
      find.byKey(const ValueKey('outerInline')),
    );
    expect(outer.size.height, greaterThanOrEqualTo(70));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline vertical margins contribute to line box height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(240),
            height: const AutoSize(),
            children: const [
              HtmlDiv(
                key: ValueKey('margined'),
                display: HtmlDisplay.inline,
                width: FixedSize(80),
                height: FixedSize(20),
                margin: HtmlMargin.only(
                  top: HtmlLength.px(10),
                  bottom: HtmlLength.px(6),
                ),
              ),
              HtmlDiv(
                key: ValueKey('plain'),
                display: HtmlDisplay.inline,
                width: FixedSize(80),
                height: FixedSize(20),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final RenderBox parent = tester.renderObject(find.byType(HtmlDiv).first);
    // Baseline is bottom of tallest ascent; line height should be >= 20 + 10 + 6.
    expect(parent.size.height, greaterThanOrEqualTo(36));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'block vertical padding contributes to auto height (content-box)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: HtmlDiv(
              width: FixedSize(200),
              height: AutoSize(),
              children: [
                HtmlDiv(
                  key: ValueKey('padded'),
                  padding: HtmlPadding.only(
                    top: HtmlLength.px(10),
                    bottom: HtmlLength.px(20),
                  ),
                  children: [
                    SizedBox(key: ValueKey('inner'), width: 40, height: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Size paddedSize = tester.getSize(
        find.byKey(const ValueKey('padded')),
      );
      expect(paddedSize.height, equals(60));

      final Offset paddedTop = tester.getTopLeft(
        find.byKey(const ValueKey('padded')),
      );
      final Offset innerTop = tester.getTopLeft(
        find.byKey(const ValueKey('inner')),
      );
      expect(innerTop.dy - paddedTop.dy, equals(10));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'block vertical padding contributes to auto height (border-box)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: HtmlDiv(
              width: FixedSize(200),
              height: AutoSize(),
              children: [
                HtmlDiv(
                  key: ValueKey('padded'),
                  boxSizing: HtmlBoxSizing.borderBox,
                  padding: HtmlPadding.only(
                    top: HtmlLength.px(10),
                    bottom: HtmlLength.px(20),
                  ),
                  children: [
                    SizedBox(key: ValueKey('inner'), width: 40, height: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Size paddedSize = tester.getSize(
        find.byKey(const ValueKey('padded')),
      );
      expect(paddedSize.height, equals(60));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('block bottom padding prevents following siblings overlap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: FixedSize(200),
            height: AutoSize(),
            children: [
              HtmlDiv(
                key: ValueKey('padded'),
                padding: HtmlPadding.only(
                  top: HtmlLength.px(10),
                  bottom: HtmlLength.px(20),
                ),
                children: [
                  SizedBox(key: ValueKey('inner'), width: 40, height: 30),
                ],
              ),
              SizedBox(key: ValueKey('after'), width: 10, height: 5),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Rect innerRect = tester.getRect(find.byKey(const ValueKey('inner')));
    final Rect afterRect = tester.getRect(find.byKey(const ValueKey('after')));

    // The following sibling should start after the padded box's padding-bottom.
    // innerRect.bottom is at padding-top + child height; add padding-bottom.
    expect(afterRect.top, closeTo(innerRect.bottom + 20, 0.001));
    expect(tester.takeException(), isNull);
  });
}
