import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

void main() {
  testWidgets('HtmlDiv MinContent with Text', (WidgetTester tester) async {
    // "Hello World"
    // MinContent should be the width of "Hello" or "World" (whichever is wider),
    // effectively wrapping at every opportunity.
    // However, Flutter's Text widget's minIntrinsicWidth is usually the width of the widest word.

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const MinContent(),
            height: const AutoSize(),
            children: [const Text('Hello World')],
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);

    // We can't easily predict the exact pixel width of text without a specific font loader in tests,
    // but we can compare it against the text's intrinsic width.
    final textFinder = find.byType(HtmlText);
    final RenderBox textBox = tester.renderObject(textFinder);

    // The HtmlDiv width should match the Text's min intrinsic width
    expect(renderBox.size.width, textBox.getMinIntrinsicWidth(double.infinity));
  });

  testWidgets('HtmlDiv MaxContent with Text', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const MaxContent(),
            height: const AutoSize(),
            children: [const Text('Hello World')],
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);

    final textFinder = find.byType(HtmlText);
    final RenderBox textBox = tester.renderObject(textFinder);

    // The HtmlDiv width should match the Text's max intrinsic width (no wrapping)
    expect(renderBox.size.width, textBox.getMaxIntrinsicWidth(double.infinity));
  });

  testWidgets('HtmlDiv FitContent with Text (Unconstrained)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FitContent(),
            height: const AutoSize(),
            children: [const Text('Hello World')],
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);

    final textFinder = find.byType(HtmlText);
    final RenderBox textBox = tester.renderObject(textFinder);

    // Unconstrained, FitContent should behave like MaxContent
    expect(renderBox.size.width, textBox.getMaxIntrinsicWidth(double.infinity));
  });

  testWidgets('HtmlDiv FitContent with Text (Constrained)', (
    WidgetTester tester,
  ) async {
    // Constrain the width to be less than MaxContent but more than MinContent
    // We need a way to know the text width.
    // Let's use a SizedBox child instead of Text for predictable sizing in this specific test case.

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 100, // Constraint
            child: HtmlDiv(
              width: const FitContent(),
              height: const AutoSize(),
              children: [
                // Child with min=50, max=150
                // We can simulate this with a custom RenderBox or just use a Container
                // that doesn't shrink?
                // Actually, let's use nested HtmlDivs or SizedBoxes.
                // A simple SizedBox has min=max=width.
                // We need something with different min/max.
                // Text is the best candidate.
                // Let's assume "Hello World" is wider than 100? Maybe not.
                // Let's use a long string.
                const Text('Hello World This Is A Long String'),
              ],
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);

    // It should fit the available space (100) because max intrinsic is large,
    // but available is 100.
    expect(renderBox.size.width, 100);
  });

  testWidgets('HtmlDiv Nested MinContent', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const MinContent(),
            height: const AutoSize(),
            children: [
              HtmlDiv(width: const FixedSize(50), height: const FixedSize(50)),
              HtmlDiv(width: const FixedSize(100), height: const FixedSize(50)),
            ],
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv).first;
    final RenderBox renderBox = tester.renderObject(finder);

    // Should be width of widest child (100)
    expect(renderBox.size.width, 100);
  });
}
