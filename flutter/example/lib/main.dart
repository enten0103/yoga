import 'package:flutter/material.dart';
import 'pages/fixed_size_page.dart';
import 'pages/percent_size_page.dart';
import 'pages/auto_size_width_page.dart';
import 'pages/auto_size_height_page.dart';
import 'pages/nested_layout_page.dart';
import 'pages/min_content_width_page.dart';
import 'pages/border_demo_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HtmlDiv Examples',
      home: const HomePage(),
    );
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
            title: const Text('HtmlDiv 固定尺寸布局'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FixedSizePage())),
          ),
          ListTile(
            title: const Text('HtmlDiv 百分比尺寸布局'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PercentSizePage())),
          ),
          ListTile(
            title: const Text('HtmlDiv 自动宽度'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AutoSizeWidthPage())),
          ),
          ListTile(
            title: const Text('HtmlDiv 自动高度'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AutoSizeHeightPage())),
          ),
          ListTile(
            title: const Text('HtmlDiv 嵌套布局'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NestedLayoutPage())),
          ),
          ListTile(
            title: const Text('HtmlDiv 最小内容宽度'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MinContentWidthPage())),
          ),
          ListTile(
            title: const Text('HtmlDiv 边框与盒模型示例'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BorderDemoPage())),
          ),
        ],
      ),
    );
  }
}
