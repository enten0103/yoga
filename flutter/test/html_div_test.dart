import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/html_div.dart';

void main() {
  testWidgets('HtmlDiv FixedSize layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(100),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    expect(finder, findsOneWidget);

    final RenderBox renderBox = tester.renderObject(finder);
    expect(renderBox.size, const Size(100, 100));
  });

  testWidgets('HtmlDiv PercentSize layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            // 使用 Center 放宽 HtmlDiv 的约束
            child: Center(
              child: HtmlDiv(
                width: const PercentSize(50),
                height: const PercentSize(25),
              ),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);
    
    // 200 的 50% = 100
    // 200 的 25% = 50
    expect(renderBox.size, const Size(100, 50));
  });

  testWidgets('HtmlDiv AutoSize width (Block behavior)', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            // 使用 Align 放宽约束但保留最大可用宽度
            child: Align(
              alignment: Alignment.topLeft,
              child: HtmlDiv(
                width: const AutoSize(), // 应填满宽度
                height: const FixedSize(50),
              ),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);
    
    expect(renderBox.size.width, 300);
    expect(renderBox.size.height, 50);
  });

  testWidgets('HtmlDiv AutoSize height (Content wrapping)', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 300,
            // 使用 Align 放宽约束
            child: Align(
              alignment: Alignment.topLeft,
              child: HtmlDiv(
                width: const FixedSize(100),
                height: const AutoSize(), // 应包裹内容
                children: [
                  SizedBox(width: 50, height: 20),
                  SizedBox(width: 50, height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);
    
    // 高度应为子节点高度之和：20 + 30 = 50
    expect(renderBox.size.height, 50);
    expect(renderBox.size.width, 100);
  });

  testWidgets('HtmlDiv nested layout (Vertical stacking)', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(200),
            height: const AutoSize(),
            children: [
              HtmlDiv(
                width: const FixedSize(100),
                height: const FixedSize(50),
              ),
              HtmlDiv(
                width: const FixedSize(100),
                height: const FixedSize(50),
              ),
            ],
          ),
        ),
      ),
    );

    final parentFinder = find.byType(HtmlDiv).first;
    final RenderBox parentBox = tester.renderObject(parentFinder);
    
    // 父节点高度应为 50 + 50 = 100
    expect(parentBox.size.height, 100);
    
    // 验证子节点位置
    // 我们需要找到 RenderHtmlDiv 子节点。
    // 由于 find.byType(HtmlDiv) 返回 widget，我们可以遍历它们。
    // 或者简单地检查父节点的子节点（如果需要），或者直接相信高度计算意味着堆叠。
    // 让我们验证第二个子节点在第一个之下。
    
    final children = find.descendant(of: parentFinder, matching: find.byType(HtmlDiv));
    expect(children, findsNWidgets(2));
    
    final child1 = tester.renderObject(children.at(0)) as RenderBox;
    final child2 = tester.renderObject(children.at(1)) as RenderBox;
    
    final parentPos = parentBox.localToGlobal(Offset.zero);
    final child1Pos = child1.localToGlobal(Offset.zero);
    final child2Pos = child2.localToGlobal(Offset.zero);
    
    expect(child1Pos.dy, parentPos.dy);
    expect(child2Pos.dy, parentPos.dy + 50);
  });
  
  testWidgets('HtmlDiv MinContent width', (WidgetTester tester) async {
    // MinContent 应该是最宽子节点的最小固有宽度？
    // 或者如果它们是固定的，就是最宽的子节点？
    // 让我们用固定宽度的子节点进行测试。
    
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const MinContent(),
            height: const AutoSize(),
            children: [
              SizedBox(width: 50, height: 20),
              SizedBox(width: 80, height: 20),
            ],
          ),
        ),
      ),
    );

    final finder = find.byType(HtmlDiv);
    final RenderBox renderBox = tester.renderObject(finder);
    
    // MinContent 应收缩至最宽子节点 (80)
    expect(renderBox.size.width, 80);
  });
}
