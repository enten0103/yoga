import 'package:flutter/material.dart';
import 'pages/fixed_size_page.dart';
import 'pages/percent_size_page.dart';
import 'pages/auto_size_width_page.dart';
import 'pages/auto_size_height_page.dart';
import 'pages/nested_layout_page.dart';
import 'pages/min_content_width_page.dart';
import 'pages/border_demo_page.dart';
import 'pages/content_sizing_demo_page.dart';
import 'pages/border_radius_page.dart';
import 'pages/border_image_page.dart';
import 'pages/background_page.dart';
import 'pages/box_shadow_page.dart';
import 'pages/margin_page.dart';
import 'pages/padding_page.dart';
import 'pages/transform_page.dart';
import 'pages/inline_page.dart';
import 'pages/css_paint_order_page.dart';
import 'pages/min_max_size_page.dart';
import 'pages/flex_layout_page.dart';
import 'pages/flex_image_interaction_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'HtmlDiv Examples', home: const HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv 示例')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('HtmlDiv Flex (Yoga) 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FlexLayoutPage()),
            ),
          ),
          ListTile(
            title: const Text('Flex × Image 交互示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FlexImageInteractionPage(),
              ),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv 固定尺寸布局'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FixedSizePage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv 百分比尺寸布局'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PercentSizePage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv 自动宽度'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AutoSizeWidthPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv 自动高度'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AutoSizeHeightPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv 嵌套布局'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NestedLayoutPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv 最小内容宽度'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MinContentWidthPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv 边框与盒模型示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BorderDemoPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv 内容尺寸示例 (Min/Max/Fit)'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContentSizingDemoPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv Min/Max-Width/Height 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MinMaxSizePage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv 圆角边框示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BorderRadiusPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv Border-Image 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BorderImagePage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv Background 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BackgroundPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv Box-Shadow 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BoxShadowPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv Margin 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MarginPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv Padding 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaddingPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv Transform 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransformPage()),
            ),
          ),
          ListTile(
            title: const Text('HtmlDiv Inline / Baseline / Text 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InlinePage()),
            ),
          ),
          ListTile(
            title: const Text('CSS 重叠/绘制顺序对照 (index.html)'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CssPaintOrderPage()),
            ),
          ),
        ],
      ),
    );
  }
}
