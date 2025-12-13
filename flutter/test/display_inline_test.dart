import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

void main() {
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
}
