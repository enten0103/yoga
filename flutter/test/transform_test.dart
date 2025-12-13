import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

void main() {
  testWidgets('HtmlDiv transform does not affect layout size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(120),
            height: const FixedSize(80),
            boxSizing: HtmlBoxSizing.contentBox,
            border: HtmlBorder.all(
              width: const FixedBorderWidth(10),
              style: HtmlBorderStyle.solid,
              color: const Color(0x1A000000),
            ),
            background: const HtmlBackground(color: Colors.white),
            transform: HtmlTransform(
              matrix: Matrix4.identity()..rotateZ(15 * math.pi / 180.0),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final RenderBox renderBox = tester.renderObject(find.byType(HtmlDiv));
    // content 120x80 + border 10*2
    expect(renderBox.size, const Size(140, 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('HtmlDiv transform participates in hit testing', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(180),
            height: const FixedSize(90),
            background: const HtmlBackground(color: Colors.white),
            transform: HtmlTransform(
              originAlignment: Alignment.center,
              matrix: Matrix4.identity()
                ..translate(24.0, 10.0)
                ..rotateZ(20 * math.pi / 180.0)
                ..scale(1.05, 1.05),
            ),
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => tapped = true,
                child: const SizedBox(width: 180, height: 90),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();

    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
