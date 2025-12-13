import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

void main() {
  testWidgets('Vertical margins collapse between siblings', (
    WidgetTester tester,
  ) async {
    const parentKey = ValueKey('parent');
    const aKey = ValueKey('a');
    const bKey = ValueKey('b');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            key: parentKey,
            width: const FixedSize(200),
            children: const [
              HtmlDiv(
                key: aKey,
                width: FixedSize(200),
                height: FixedSize(20),
                margin: HtmlMargin.only(bottom: HtmlLength.px(20)),
                background: HtmlBackground(color: Color(0xFFE8F5E9)),
              ),
              HtmlDiv(
                key: bKey,
                width: FixedSize(200),
                height: FixedSize(20),
                margin: HtmlMargin.only(
                  top: HtmlLength.px(10),
                  bottom: HtmlLength.px(15),
                ),
                background: HtmlBackground(color: Color(0xFFE3F2FD)),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset aTopLeft = tester.getTopLeft(find.byKey(aKey));
    final Offset bTopLeft = tester.getTopLeft(find.byKey(bKey));

    // A at y=0; space between A and B is collapse(20,10)=20.
    expect(bTopLeft.dy - aTopLeft.dy, 40);

    final RenderBox parentBox = tester.renderObject(find.byKey(parentKey));
    // height = 20 + 20 + 20 + 15
    expect(parentBox.size.height, 75);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mixed-sign margins collapse as sum', (
    WidgetTester tester,
  ) async {
    const aKey = ValueKey('a2');
    const bKey = ValueKey('b2');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(200),
            children: const [
              HtmlDiv(
                key: aKey,
                width: FixedSize(200),
                height: FixedSize(20),
                margin: HtmlMargin.only(bottom: HtmlLength.px(-10)),
                background: HtmlBackground(color: Color(0xFFFFF3E0)),
              ),
              HtmlDiv(
                key: bKey,
                width: FixedSize(200),
                height: FixedSize(20),
                margin: HtmlMargin.only(top: HtmlLength.px(20)),
                background: HtmlBackground(color: Color(0xFFF3E5F5)),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset aTopLeft = tester.getTopLeft(find.byKey(aKey));
    final Offset bTopLeft = tester.getTopLeft(find.byKey(bKey));

    // space is collapse(-10,20)=10, so B is at y=20+10=30.
    expect(bTopLeft.dy - aTopLeft.dy, 30);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Negative top margin pulls block upward (overlap)', (
    WidgetTester tester,
  ) async {
    const aKey = ValueKey('negTopA');
    const bKey = ValueKey('negTopB');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: HtmlDiv(
            width: const FixedSize(200),
            children: const [
              HtmlDiv(
                key: aKey,
                width: FixedSize(200),
                height: FixedSize(40),
                background: HtmlBackground(color: Color(0xFFE8F5E9)),
              ),
              HtmlDiv(
                key: bKey,
                width: FixedSize(200),
                height: FixedSize(40),
                margin: HtmlMargin.only(top: HtmlLength.px(-10)),
                background: HtmlBackground(color: Color(0xFFE3F2FD)),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset aTopLeft = tester.getTopLeft(find.byKey(aKey));
    final Offset bTopLeft = tester.getTopLeft(find.byKey(bKey));

    // A height=40; collapse(0,-10)=-10 => B starts at y=30 (overlaps by 10).
    expect(bTopLeft.dy - aTopLeft.dy, 30);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Negative horizontal margins shift and expand available width', (
    WidgetTester tester,
  ) async {
    const parentKey = ValueKey('negHMParent');
    const childKey = ValueKey('negHMChild');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: HtmlDiv(
            key: parentKey,
            width: const FixedSize(200),
            children: const [
              HtmlDiv(
                key: childKey,
                width: AutoSize(),
                height: FixedSize(20),
                margin: HtmlMargin.only(
                  left: HtmlLength.px(-20),
                  right: HtmlLength.px(-20),
                ),
                background: HtmlBackground(color: Color(0xFFFFF3E0)),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset parentTopLeft = tester.getTopLeft(find.byKey(parentKey));
    final Offset childTopLeft = tester.getTopLeft(find.byKey(childKey));
    final RenderBox childBox = tester.renderObject(find.byKey(childKey));

    // Negative left margin shifts left.
    expect(childTopLeft.dx - parentTopLeft.dx, -20);
    // AutoSize block fills the provided maxWidth; negative margins expand it.
    // parent contentWidth=200, m.horizontal=-40 => child maxWidth=240.
    expect(childBox.size.width, equals(240));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Horizontal auto margins distribute remaining space', (
    WidgetTester tester,
  ) async {
    const parentKey = ValueKey('p3');
    const centerKey = ValueKey('c');
    const rightAutoKey = ValueKey('ra');
    const leftAutoKey = ValueKey('la');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: HtmlDiv(
            key: parentKey,
            width: const FixedSize(200),
            children: const [
              HtmlDiv(
                key: centerKey,
                width: FixedSize(100),
                height: FixedSize(20),
                margin: HtmlMargin.only(
                  left: HtmlLength.auto(),
                  right: HtmlLength.auto(),
                ),
                background: HtmlBackground(color: Color(0xFFE3F2FD)),
              ),
              HtmlDiv(
                key: rightAutoKey,
                width: FixedSize(100),
                height: FixedSize(20),
                margin: HtmlMargin.only(
                  left: HtmlLength.px(20),
                  right: HtmlLength.auto(),
                  top: HtmlLength.px(10),
                ),
                background: HtmlBackground(color: Color(0xFFE8F5E9)),
              ),
              HtmlDiv(
                key: leftAutoKey,
                width: FixedSize(100),
                height: FixedSize(20),
                margin: HtmlMargin.only(
                  left: HtmlLength.auto(),
                  right: HtmlLength.px(20),
                  top: HtmlLength.px(10),
                ),
                background: HtmlBackground(color: Color(0xFFFFF3E0)),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset parentTopLeft = tester.getTopLeft(find.byKey(parentKey));

    final Offset centerTopLeft = tester.getTopLeft(find.byKey(centerKey));
    // (200 - 100) / 2
    expect(centerTopLeft.dx - parentTopLeft.dx, 50);

    final Offset rightAutoTopLeft = tester.getTopLeft(find.byKey(rightAutoKey));
    expect(rightAutoTopLeft.dx - parentTopLeft.dx, 20);

    final Offset leftAutoTopLeft = tester.getTopLeft(find.byKey(leftAutoKey));
    // remaining = 200 - 20 - 100
    expect(leftAutoTopLeft.dx - parentTopLeft.dx, 80);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Percentage margins resolve against containing block width', (
    WidgetTester tester,
  ) async {
    const parentKey = ValueKey('p4');
    const childKey = ValueKey('p4c');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: HtmlDiv(
            key: parentKey,
            width: const FixedSize(200),
            children: const [
              HtmlDiv(
                key: childKey,
                width: FixedSize(100),
                height: FixedSize(20),
                margin: HtmlMargin.only(left: HtmlLength.percent(10)),
                background: HtmlBackground(color: Color(0xFFE3F2FD)),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Offset parentTopLeft = tester.getTopLeft(find.byKey(parentKey));
    final Offset childTopLeft = tester.getTopLeft(find.byKey(childKey));
    // 10% of 200 = 20
    expect(childTopLeft.dx - parentTopLeft.dx, 20);
    expect(tester.takeException(), isNull);
  });
}
