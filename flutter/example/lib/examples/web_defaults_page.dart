import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class WebDefaultsPage extends StatefulWidget {
  const WebDefaultsPage({super.key});

  @override
  State<WebDefaultsPage> createState() => _WebDefaultsPageState();
}

class _WebDefaultsPageState extends State<WebDefaultsPage> {
  bool _useWebDefaults = false;
  bool _enableMarginCollapsing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Defaults Example')),
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
      child: Column(
        children: [
          Row(
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
          Row(
            children: [
              const Text('Enable Margin Collapsing: '),
              Switch(
                value: _enableMarginCollapsing,
                onChanged: (value) {
                  setState(() {
                    _enableMarginCollapsing = value;
                  });
                },
              ),
            ],
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
          _buildSectionTitle('1. Flex Shrink 默认值'),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '说明:\n'
              '当 "Use Web Defaults" 开启时，flexShrink 默认为 1 (而不是 0)。\n'
              '没有显式设置 flexShrink 的子项会自动收缩以适应容器。\n'
              '\n'
              '当关闭时 (Yoga 默认)，flexShrink 默认为 0。\n'
              '如果子项总宽度超过容器，将会溢出。',
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: Colors.grey[300],
            // Fixed width container to force overflow/shrinking
            width: 300,
            height: 100,
            child: YogaLayout(
              useWebDefaults: _useWebDefaults,
              flexDirection: YGFlexDirection.row,
              // We don't set flexWrap, so it defaults to noWrap.
              children: [
                _buildItem(Colors.red, 'Item 1', 100),
                _buildItem(Colors.green, 'Item 2', 100),
                _buildItem(Colors.blue, 'Item 3', 100),
                _buildItem(Colors.orange, 'Item 4', 100),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('容器宽度: 300. 子项总宽度: 400.'),
          ),
          const Divider(),
          _buildSectionTitle('2. Margin 折叠 (Margin Collapsing)'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '说明:\n'
              '在 Flexbox (Yoga) 中，垂直方向的 Margin 默认不会发生折叠 (Collapse)。\n'
              '但是，通过开启 "Enable Margin Collapsing"，我们可以模拟 Web Block 布局的行为。\n'
              '\n'
              '当前状态: ${_enableMarginCollapsing ? "开启 (折叠)" : "关闭 (累加)"}\n'
              '\n'
              '下方示例：\n'
              '红色方块 marginBottom: 20\n'
              '绿色方块 marginTop: 20\n'
              '${_enableMarginCollapsing ? "折叠后间距: 20 (max(20, 20))" : "累加后间距: 40 (20 + 20)"}',
            ),
          ),
          Container(
            color: Colors.grey[300],
            width: 300,
            height: 200,
            child: YogaLayout(
              useWebDefaults: _useWebDefaults,
              enableMarginCollapsing: _enableMarginCollapsing,
              flexDirection: YGFlexDirection.column,
              alignItems: YGAlign.center,
              justifyContent: YGJustify.center,
              children: [
                YogaItem(
                  width: 100,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: const Text(
                      'Bottom 20',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                YogaItem(
                  width: 100,
                  height: 50,
                  margin: const EdgeInsets.only(top: 20),
                  child: Container(
                    color: Colors.green,
                    alignment: Alignment.center,
                    child: const Text(
                      'Top 20',
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

  Widget _buildItem(Color color, String text, double width) {
    // We do NOT set flexShrink here, so it uses the default.
    return YogaItem(
      width: width,
      height: 80,
      child: Container(
        color: color,
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
