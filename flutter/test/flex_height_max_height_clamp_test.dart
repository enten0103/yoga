import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

void main() {
  testWidgets('flex height should be clamped by maxHeight for layout', (
    WidgetTester tester,
  ) async {
    const containerKey = ValueKey('container');
    const childKey = ValueKey('child');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: HtmlDiv(
              key: containerKey,
              display: HtmlDisplay.flex,
              flexDirection: HtmlFlexDirection.row,
              alignItems: HtmlAlignItems.stretch,
              // Height is larger than maxHeight; maxHeight should win.
              height: const FixedSize(100),
              maxHeight: const FixedSize(60),
              children: [
                HtmlDiv(
                  key: childKey,
                  width: const FixedSize(50),
                  // Auto height so it will stretch on cross axis.
                  height: const AutoSize(),
                  background: const HtmlBackground(color: Color(0xFF000000)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size containerSize = tester.getSize(find.byKey(containerKey));
    final Size childSize = tester.getSize(find.byKey(childKey));

    expect(containerSize.height, moreOrLessEquals(60, epsilon: 0.01));
    // Child should not be taller than the clamped container.
    expect(childSize.height, lessThanOrEqualTo(containerSize.height + 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('flex item height should be clamped by its maxHeight', (
    WidgetTester tester,
  ) async {
    const containerKey = ValueKey('container2');
    const childKey = ValueKey('child2');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: HtmlDiv(
              key: containerKey,
              display: HtmlDisplay.flex,
              flexDirection: HtmlFlexDirection.row,
              // Avoid stretch so the item's own height is used.
              alignItems: HtmlAlignItems.flexStart,
              children: [
                HtmlDiv(
                  key: childKey,
                  width: const FixedSize(50),
                  height: const FixedSize(100),
                  maxHeight: const FixedSize(20),
                  background: const HtmlBackground(color: Color(0xFF000000)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size childSize = tester.getSize(find.byKey(childKey));
    expect(childSize.height, moreOrLessEquals(20, epsilon: 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('flex height+maxHeight should clamp under unbounded height', (
    WidgetTester tester,
  ) async {
    const containerKey = ValueKey('container3');
    const itemKey = ValueKey('item3');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 320,
          height: 240,
          child: ListView(
            children: [
              HtmlDiv(
                key: containerKey,
                display: HtmlDisplay.flex,
                justifyContent: HtmlJustifyContent.center,
                alignItems: HtmlAlignItems.center,
                height: const FixedSize(800),
                maxHeight: const FixedSize(120),
                children: [
                  HtmlDiv(
                    key: itemKey,
                    width: const FixedSize(100),
                    height: const FixedSize(300),
                    background: const HtmlBackground(color: Color(0xFFFFC107)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size containerSize = tester.getSize(find.byKey(containerKey));
    final Size itemSize = tester.getSize(find.byKey(itemKey));

    expect(containerSize.height, moreOrLessEquals(120, epsilon: 0.01));
    expect(itemSize.height, moreOrLessEquals(300, epsilon: 0.01));

    // Regression: alignment should be computed against the clamped height.
    // With container=120 and item=300 (overflow), flexbox uses safe alignment
    // so the item should not be pushed down (top offset stays at 0).
    final Offset containerTop = tester.getTopLeft(find.byKey(containerKey));
    final Offset itemTop = tester.getTopLeft(find.byKey(itemKey));
    expect(itemTop.dy - containerTop.dy, moreOrLessEquals(0, epsilon: 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('borderBox: height+maxHeight clamps including border/padding', (
    WidgetTester tester,
  ) async {
    const containerKey = ValueKey('container4');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: HtmlDiv(
              key: containerKey,
              display: HtmlDisplay.flex,
              boxSizing: HtmlBoxSizing.borderBox,
              height: const FixedSize(200),
              maxHeight: const FixedSize(120),
              padding: const HtmlPadding.all(HtmlLength.px(10)),
              border: HtmlBorder.all(
                width: const FixedBorderWidth(10),
                style: HtmlBorderStyle.solid,
                color: const Color(0xFF000000),
              ),
              children: const [
                HtmlDiv(width: FixedSize(20), height: FixedSize(20)),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size containerSize = tester.getSize(find.byKey(containerKey));
    expect(containerSize.height, moreOrLessEquals(120, epsilon: 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('percent maxHeight clamps when parent height is bounded', (
    WidgetTester tester,
  ) async {
    const containerKey = ValueKey('container5');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240, maxHeight: 400),
            child: HtmlDiv(
              key: containerKey,
              display: HtmlDisplay.flex,
              height: const FixedSize(800),
              maxHeight: const PercentSize(50),
              children: const [
                HtmlDiv(width: FixedSize(20), height: FixedSize(20)),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size containerSize = tester.getSize(find.byKey(containerKey));
    expect(containerSize.height, moreOrLessEquals(200, epsilon: 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('minHeight > maxHeight should normalize and clamp', (
    WidgetTester tester,
  ) async {
    const containerKey = ValueKey('container6');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: HtmlDiv(
              key: containerKey,
              display: HtmlDisplay.flex,
              height: const FixedSize(10),
              minHeight: const FixedSize(80),
              maxHeight: const FixedSize(40),
              children: const [
                HtmlDiv(width: FixedSize(20), height: FixedSize(20)),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Size containerSize = tester.getSize(find.byKey(containerKey));
    expect(containerSize.height, moreOrLessEquals(80, epsilon: 0.01));
    expect(tester.takeException(), isNull);
  });
}
