import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class PaddingPage extends StatefulWidget {
  const PaddingPage({super.key});

  @override
  State<PaddingPage> createState() => _PaddingPageState();
}

class _PaddingPageState extends State<PaddingPage> {
  bool _useWebDefaults = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Padding Examples')),
      body: Column(
        children: [
          _buildControls(),
          const Divider(),
          Expanded(child: _buildLayoutDemo()),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text('Use Web Defaults: '),
          Switch(
            value: _useWebDefaults,
            onChanged: (value) {
              setState(() {
                _useWebDefaults = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutDemo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('1. 固定值 Padding (Fixed Padding)'),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '说明:\n'
              '父容器设置 padding: 20px。\n'
              '子项会被向内推挤 20px。',
            ),
          ),
          Container(
            color: Colors.grey[300],
            width: double.infinity,
            child: YogaLayout(
              display: YogaDisplay.flex,
              useWebDefaults: _useWebDefaults,
              flexDirection: YGFlexDirection.row,
              padding: const YogaEdgeInsets.all(YogaValue.point(20)),
              children: [
                YogaItem(
                  width: YogaValue.pt(100),
                  height: YogaValue.pt(50),
                  child: Container(
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: const Text(
                      'Item',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildSectionTitle('2. 百分比 Padding (Percentage Padding)'),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '说明:\n'
              '父容器设置 padding: 10% (相对于父容器宽度)。\n'
              '父容器宽度自适应 (全宽)。\n'
              '注意: 垂直方向的百分比 Padding 也是相对于宽度的 (CSS 标准)。',
            ),
          ),
          Container(
            color: Colors.grey[300],
            width: double.infinity,
            child: YogaLayout(
              display: YogaDisplay.flex,
              useWebDefaults: _useWebDefaults,
              flexDirection: YGFlexDirection.column,
              padding: const YogaEdgeInsets.all(YogaValue.percent(10)),
              children: [
                YogaItem(
                  height: YogaValue.pt(50),
                  child: Container(
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: const Text(
                      'Item inside 10% Padding',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildSectionTitle('3. 混合单位 Padding (Mixed Units)'),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '说明:\n'
              'Top/Bottom: 20px (固定)\n'
              'Left/Right: 20% (百分比)',
            ),
          ),
          Container(
            color: Colors.grey[300],
            width: double.infinity,
            child: YogaLayout(
              display: YogaDisplay.flex,
              useWebDefaults: _useWebDefaults,
              flexDirection: YGFlexDirection.column,
              padding: const YogaEdgeInsets.symmetric(
                vertical: YogaValue.point(20),
                horizontal: YogaValue.percent(20),
              ),
              children: [
                YogaItem(
                  height: YogaValue.pt(50),
                  child: Container(
                    color: Colors.green,
                    alignment: Alignment.center,
                    child: const Text(
                      'Mixed Padding',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
