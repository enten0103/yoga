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
          const Divider(),
          _buildSectionTitle('3. 父子折叠 (Parent-Child Collapsing)'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '说明:\n'
              '当父容器没有 Padding 或 Border 时，其第一个子项的 Top Margin 会与父容器的 Top Margin 折叠。\n'
              '\n'
              '当前状态: ${_enableMarginCollapsing ? "开启" : "关闭"}\n'
              '\n'
              '示例结构:\n'
              '灰色背景 (Outer)\n'
              '  蓝色背景 (Inner, 无 Padding/Border)\n'
              '    红色方块 (Child, Margin Top: 30)\n'
              '\n'
              '预期效果:\n'
              '关闭时: 蓝色容器紧贴顶部，红色方块在蓝色容器内部向下偏移 30px (露出蓝色背景)。\n'
              '开启时: 蓝色容器整体向下偏移 30px (露出灰色背景)，红色方块紧贴蓝色容器顶部。',
            ),
          ),
          Container(
            color: Colors.grey[400], // Outer background
            width: 300,
            height: 150,
            alignment: Alignment.topLeft,
            child: YogaLayout(
              useWebDefaults: _useWebDefaults,
              enableMarginCollapsing: _enableMarginCollapsing,
              flexDirection: YGFlexDirection.column,
              children: [
                // Inner Container
                YogaItem(
                  width: 200,
                  height: 100,
                  child: Container(
                    color: Colors.blue[200], // Inner background
                    child: YogaLayout(
                      // Inner layout must also enable collapsing if we want it to participate?
                      // Actually, the Outer layout runs the recursive logic.
                      // But we should set it for consistency or if it runs independently.
                      enableMarginCollapsing: _enableMarginCollapsing,
                      flexDirection: YGFlexDirection.column,
                      children: [
                        YogaItem(
                          width: 100,
                          height: 50,
                          margin: const EdgeInsets.only(top: 30),
                          child: Container(
                            color: Colors.red,
                            alignment: Alignment.center,
                            child: const Text(
                              'Margin Top 30',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildSectionTitle('4. 负 Margin 折叠 (Negative Margin Collapsing)'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '说明:\n'
              '测试负 Margin 的折叠规则。\n'
              '\n'
              'Case A: 正 + 负\n'
              '上方块 marginBottom: 20\n'
              '下方块 marginTop: -10\n'
              '结果: 20 + (-10) = 10\n'
              '\n'
              'Case B: 负 + 负\n'
              '上方块 marginBottom: -10\n'
              '下方块 marginTop: -20\n'
              '结果: min(-10, -20) = -20',
            ),
          ),
          Container(
            color: Colors.grey[300],
            width: 300,
            child: Column(
              children: [
                const Text('Case A: 20 + (-10) = 10'),
                Container(
                  color: Colors.white,
                  height: 150,
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
                          child: const Text('Bottom 20'),
                        ),
                      ),
                      YogaItem(
                        width: 100,
                        height: 50,
                        margin: const EdgeInsets.only(top: -10),
                        child: Container(
                          color: Colors.green,
                          alignment: Alignment.center,
                          child: const Text('Top -10'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Case B: -10 + (-20) = -20'),
                Container(
                  color: Colors.white,
                  height: 150,
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
                        margin: const EdgeInsets.only(bottom: -10),
                        child: Container(
                          color: Colors.red,
                          alignment: Alignment.center,
                          child: const Text('Bottom -10'),
                        ),
                      ),
                      YogaItem(
                        width: 100,
                        height: 50,
                        margin: const EdgeInsets.only(top: -20),
                        child: Container(
                          color: Colors.green,
                          alignment: Alignment.center,
                          child: const Text('Top -20'),
                        ),
                      ),
                    ],
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
