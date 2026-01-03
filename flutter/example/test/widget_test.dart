// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_yoga_example/main.dart';

void main() {
  testWidgets('Home page renders and navigates to Border-Image demo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'HtmlDiv 示例'), findsOneWidget);

    final listFinder = find.byType(Scrollable);
    final itemFinder = find.text('HtmlDiv Border-Image 示例');
    await tester.scrollUntilVisible(itemFinder, 200, scrollable: listFinder);
    expect(itemFinder, findsOneWidget);

    await tester.ensureVisible(itemFinder);
    await tester.pumpAndSettle();

    await tester.tap(itemFinder);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(AppBar, 'HtmlDiv Border-Image 示例'),
      findsOneWidget,
    );
  });

  testWidgets('Home page navigates to Background demo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final listFinder = find.byType(Scrollable);
    final itemFinder = find.text('HtmlDiv Background 示例');
    await tester.scrollUntilVisible(itemFinder, 200, scrollable: listFinder);
    expect(itemFinder, findsOneWidget);

    await tester.ensureVisible(itemFinder);
    await tester.pumpAndSettle();

    await tester.tap(itemFinder);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(AppBar, 'HtmlDiv Background 示例'),
      findsOneWidget,
    );
  });

  testWidgets('Home page navigates to Box-Shadow demo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final listFinder = find.byType(Scrollable);
    final itemFinder = find.text('HtmlDiv Box-Shadow 示例');
    await tester.scrollUntilVisible(itemFinder, 200, scrollable: listFinder);
    expect(itemFinder, findsOneWidget);

    await tester.ensureVisible(itemFinder);
    await tester.pumpAndSettle();

    await tester.tap(itemFinder);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(AppBar, 'HtmlDiv Box-Shadow 示例'),
      findsOneWidget,
    );
  });

  testWidgets('Home page navigates to Transform demo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final listFinder = find.byType(Scrollable);
    final itemFinder = find.text('HtmlDiv Transform 示例');
    await tester.scrollUntilVisible(itemFinder, 200, scrollable: listFinder);
    expect(itemFinder, findsOneWidget);

    await tester.ensureVisible(itemFinder);
    await tester.pumpAndSettle();

    await tester.tap(itemFinder);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'HtmlDiv Transform 示例'), findsOneWidget);
  });

  testWidgets('Home page navigates to Margin demo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final listFinder = find.byType(Scrollable);
    final itemFinder = find.text('HtmlDiv Margin 示例');
    await tester.scrollUntilVisible(itemFinder, 200, scrollable: listFinder);
    expect(itemFinder, findsOneWidget);

    await tester.ensureVisible(itemFinder);
    await tester.pumpAndSettle();

    await tester.tap(itemFinder);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'HtmlDiv Margin 示例'), findsOneWidget);
  });

  testWidgets('Home page navigates to Flex × Image demo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final listFinder = find.byType(Scrollable);
    final itemFinder = find.text('Flex × Image 交互示例');
    await tester.scrollUntilVisible(itemFinder, 200, scrollable: listFinder);
    expect(itemFinder, findsOneWidget);

    await tester.ensureVisible(itemFinder);
    await tester.pumpAndSettle();

    await tester.tap(itemFinder);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Flex × Image 交互示例'), findsOneWidget);
  });
}
