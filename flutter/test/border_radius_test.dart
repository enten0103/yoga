import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

void main() {
  testWidgets('HtmlDiv with BorderRadius renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(100),
            border: HtmlBorder.all(color: Colors.red),
            borderRadius: const HtmlBorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    expect(finder, findsOneWidget);

    final RenderHtmlDiv renderBox = tester.renderObject(finder) as RenderHtmlDiv;
    expect(renderBox.borderRadius?.topLeft, const Radius.circular(10));
  });

  testWidgets('HtmlDiv with BorderRadius.only', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(100),
            border: HtmlBorder.all(color: Colors.red),
            borderRadius: const HtmlBorderRadius.only(
              topLeft: Radius.circular(10),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderHtmlDiv renderBox = tester.renderObject(finder) as RenderHtmlDiv;
    expect(renderBox.borderRadius?.topLeft, const Radius.circular(10));
    expect(renderBox.borderRadius?.topRight, Radius.zero);
    expect(renderBox.borderRadius?.bottomRight, const Radius.circular(20));
  });

  testWidgets('HtmlDiv with BorderRadius.vertical', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(100),
            border: HtmlBorder.all(color: Colors.red),
            borderRadius: const HtmlBorderRadius.vertical(
              top: Radius.circular(10),
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderHtmlDiv renderBox = tester.renderObject(finder) as RenderHtmlDiv;
    expect(renderBox.borderRadius?.topLeft, const Radius.circular(10));
    expect(renderBox.borderRadius?.topRight, const Radius.circular(10));
    expect(renderBox.borderRadius?.bottomLeft, const Radius.circular(20));
    expect(renderBox.borderRadius?.bottomRight, const Radius.circular(20));
  });

  testWidgets('HtmlDiv with BorderRadius.horizontal', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(100),
            border: HtmlBorder.all(color: Colors.red),
            borderRadius: const HtmlBorderRadius.horizontal(
              left: Radius.circular(10),
              right: Radius.circular(20),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderHtmlDiv renderBox = tester.renderObject(finder) as RenderHtmlDiv;
    expect(renderBox.borderRadius?.topLeft, const Radius.circular(10));
    expect(renderBox.borderRadius?.bottomLeft, const Radius.circular(10));
    expect(renderBox.borderRadius?.topRight, const Radius.circular(20));
    expect(renderBox.borderRadius?.bottomRight, const Radius.circular(20));
  });

  testWidgets('HtmlDiv paints without error for all BorderStyles with BorderRadius', (WidgetTester tester) async {
    for (final style in HtmlBorderStyle.values) {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: HtmlDiv(
              width: const FixedSize(100),
              height: const FixedSize(100),
              border: HtmlBorder.all(
                color: Colors.blue,
                width: const FixedBorderWidth(5),
                style: style,
              ),
              borderRadius: const HtmlBorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      );
      
      // Trigger a frame to ensure paint is called
      await tester.pumpAndSettle();
      
      expect(find.byType(HtmlDiv), findsOneWidget);
    }
  });
}
