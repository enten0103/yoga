import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

void main() {
  testWidgets('HtmlDiv box-shadow does not affect layout size', (
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
            boxShadow: const [
              HtmlBoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 8),
                blurRadius: 18,
                spreadRadius: 2,
              ),
              HtmlBoxShadow(
                inset: true,
                color: Color(0x22000000),
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
            border: HtmlBorder.all(
              width: const FixedBorderWidth(10),
              style: HtmlBorderStyle.solid,
            ),
            background: const HtmlBackground(color: Colors.white),
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

  testWidgets('HtmlDiv box-shadow variants paint without error', (
    WidgetTester tester,
  ) async {
    final List<List<HtmlBoxShadow>> variants = <List<HtmlBoxShadow>>[
      const <HtmlBoxShadow>[
        HtmlBoxShadow(
          color: Color(0x33000000),
          offset: Offset(0, 10),
          blurRadius: 22,
        ),
      ],
      const <HtmlBoxShadow>[
        HtmlBoxShadow(
          color: Color(0x33000000),
          offsetPercent: Offset(10, 12),
          blurRadius: 18,
          spreadRadius: 1,
        ),
      ],
      const <HtmlBoxShadow>[
        HtmlBoxShadow(
          color: Color(0x1F000000),
          offset: Offset(0, 12),
          blurRadius: 28,
        ),
        HtmlBoxShadow(
          color: Color(0x12000000),
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ],
      const <HtmlBoxShadow>[
        HtmlBoxShadow(
          inset: true,
          color: Color(0x55000000),
          offset: Offset(0, 6),
          blurRadius: 14,
        ),
      ],
      const <HtmlBoxShadow>[
        HtmlBoxShadow(
          color: Color(0x26000000),
          offset: Offset(0, 10),
          blurRadius: 22,
        ),
        HtmlBoxShadow(
          inset: true,
          color: Color(0x44000000),
          offset: Offset(0, 6),
          blurRadius: 14,
        ),
      ],
    ];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListView.builder(
          itemCount: variants.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: HtmlDiv(
                width: const FixedSize(180),
                height: const FixedSize(70),
                background: const HtmlBackground(color: Color(0xFFFDFDFD)),
                borderRadius: index.isEven
                    ? const HtmlBorderRadius.all(Radius.circular(14))
                    : null,
                boxShadow: variants[index],
                border: HtmlBorder.all(
                  width: const FixedBorderWidth(2),
                  style: HtmlBorderStyle.solid,
                  color: const Color(0x1A000000),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(HtmlDiv), findsNWidgets(variants.length));
    expect(tester.takeException(), isNull);
  });
}
