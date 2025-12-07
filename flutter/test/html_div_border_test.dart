import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

void main() {
  testWidgets('HtmlDiv BoxSizing.contentBox adds border to size', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(100),
            boxSizing: HtmlBoxSizing.contentBox,
            border: HtmlBorder.all(
              width: const FixedBorderWidth(10),
              style: HtmlBorderStyle.solid,
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);
    
    // Content 100 + Border 10*2 = 120
    expect(renderBox.size, const Size(120, 120));
  });

  testWidgets('HtmlDiv BoxSizing.borderBox includes border in size', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(100),
            boxSizing: HtmlBoxSizing.borderBox,
            border: HtmlBorder.all(
              width: const FixedBorderWidth(10),
              style: HtmlBorderStyle.solid,
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);
    
    // Total size should be exactly 100
    expect(renderBox.size, const Size(100, 100));
  });

  testWidgets('HtmlDiv Border Width Keywords', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(100),
            boxSizing: HtmlBoxSizing.contentBox,
            border: HtmlBorder.all(
              width: const KeywordBorderWidth(BorderWidthKeyword.thick), // 5.0
              style: HtmlBorderStyle.solid,
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);
    
    // 100 + 5*2 = 110
    expect(renderBox.size, const Size(110, 110));
  });

  testWidgets('HtmlDiv Percent Border Width', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Center(
              child: HtmlDiv(
                width: const FixedSize(100),
                height: const FixedSize(100),
                boxSizing: HtmlBoxSizing.contentBox,
                border: HtmlBorder.all(
                  width: const PercentBorderWidth(10), // 10% of 200 = 20
                  style: HtmlBorderStyle.solid,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);
    
    // Border width = 20
    // Total size = 100 + 20*2 = 140
    expect(renderBox.size, const Size(140, 140));
  });

  testWidgets('HtmlDiv Mixed Borders', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(100),
            boxSizing: HtmlBoxSizing.contentBox,
            border: const HtmlBorder(
              top: HtmlBorderSide(width: FixedBorderWidth(10)),
              left: HtmlBorderSide(width: FixedBorderWidth(20)),
              // right and bottom default to hidden/0
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);
    
    // Width = 100 + 20 (left) + 0 (right) = 120
    // Height = 100 + 10 (top) + 0 (bottom) = 110
    expect(renderBox.size, const Size(120, 110));
  });
}
