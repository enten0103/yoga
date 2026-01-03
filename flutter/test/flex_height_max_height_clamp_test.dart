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
}
