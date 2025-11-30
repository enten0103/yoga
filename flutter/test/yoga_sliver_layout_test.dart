import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

void main() {
  testWidgets('YogaLayout with scroll: true renders CustomScrollView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: YogaLayout(
            scroll: true,
            flexDirection: YGFlexDirection.column,
            children: [
              Container(height: 100, color: Colors.red),
              Container(height: 100, color: Colors.blue),
            ],
          ),
        ),
      ),
    );

    // Verify that a CustomScrollView is present
    expect(find.byType(CustomScrollView), findsOneWidget);

    // Verify that the children are present (at least the first ones)
    expect(find.byType(Container), findsNWidgets(2));
  });

  testWidgets('YogaLayout vertical scroll logic', (WidgetTester tester) async {
    // Create enough children to exceed the viewport
    final children = List.generate(
      20,
      (index) => Container(
        key: ValueKey('child_$index'),
        height: 100,
        color: index % 2 == 0 ? Colors.red : Colors.blue,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500, // Viewport height
            child: YogaLayout(
              scroll: true,
              flexDirection: YGFlexDirection.column,
              children: children,
            ),
          ),
        ),
      ),
    );

    // Initial state: child 0 should be visible
    expect(find.byKey(const ValueKey('child_0')), findsOneWidget);

    // Child 19 should not be visible initially (20 * 100 = 2000 height, viewport 500)
    expect(find.byKey(const ValueKey('child_19')), findsNothing);

    // Scroll to bottom
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pump(); // Start scroll
    await tester.pump(const Duration(milliseconds: 500)); // Animation/Settling

    // Scroll more to ensure we reach further down
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pump();

    // After scrolling, later children should be visible
    // Note: Exact visibility depends on physics and cache extent, but we expect *some* later child
    // We can check if child_0 is gone and child_10 is present
    expect(find.byKey(const ValueKey('child_0')), findsNothing);
    expect(find.byKey(const ValueKey('child_15')), findsOneWidget);
  });

  testWidgets('YogaLayout horizontal scroll logic', (
    WidgetTester tester,
  ) async {
    final children = List.generate(
      20,
      (index) => Container(
        key: ValueKey('child_$index'),
        width: 100,
        color: index % 2 == 0 ? Colors.red : Colors.blue,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500, // Viewport width
            height: 200,
            child: YogaLayout(
              scroll: true,
              flexDirection: YGFlexDirection.row,
              children: children,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('child_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('child_19')), findsNothing);

    // Scroll horizontally
    await tester.drag(find.byType(CustomScrollView), const Offset(-1000, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.drag(find.byType(CustomScrollView), const Offset(-1000, 0));
    await tester.pump();

    expect(find.byKey(const ValueKey('child_0')), findsNothing);
    expect(find.byKey(const ValueKey('child_15')), findsOneWidget);
  });
}
