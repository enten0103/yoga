import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class MarginPage extends StatelessWidget {
  const MarginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv Margin 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            title: '相邻垂直边距折叠：max / min / sum',
            child: _stack(
              children: const [
                _Block(
                  label: 'A: height 40, margin-bottom 20',
                  height: 40,
                  margin: HtmlMargin.only(bottom: HtmlLength.px(20)),
                  color: Color(0xFFE8F5E9),
                ),
                _Block(
                  label: 'B: height 40, margin-top 10',
                  height: 40,
                  margin: HtmlMargin.only(top: HtmlLength.px(10)),
                  color: Color(0xFFE3F2FD),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: '负边距：不同符号时相加',
            child: _stack(
              children: const [
                _Block(
                  label: 'A: height 40, margin-bottom -10',
                  height: 40,
                  margin: HtmlMargin.only(bottom: HtmlLength.px(-10)),
                  color: Color(0xFFFFF3E0),
                ),
                _Block(
                  label: 'B: height 40, margin-top 20',
                  height: 40,
                  margin: HtmlMargin.only(top: HtmlLength.px(20)),
                  color: Color(0xFFF3E5F5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: '水平边距：影响可用宽度与 x 偏移',
            child: _stack(
              children: const [
                _Block(
                  label: 'left 24 / right 48',
                  height: 44,
                  margin: HtmlMargin.only(
                    left: HtmlLength.px(24),
                    right: HtmlLength.px(48),
                    top: HtmlLength.px(8),
                  ),
                  color: Color(0xFFFFEBEE),
                ),
                _Block(
                  label: 'left 48 / right 24',
                  height: 44,
                  margin: HtmlMargin.only(
                    left: HtmlLength.px(48),
                    right: HtmlLength.px(24),
                    top: HtmlLength.px(8),
                  ),
                  color: Color(0xFFE0F7FA),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: '百分比边距：相对包含块宽度解析',
            child: _stack(
              children: const [
                _Block(
                  label: 'left:10% right:0',
                  width: FixedSize(180),
                  height: 44,
                  margin: HtmlMargin.only(
                    left: HtmlLength.percent(10),
                    top: HtmlLength.px(8),
                  ),
                  color: Color(0xFFFFF3E0),
                ),
                _Block(
                  label: 'left:0 right:10%',
                  width: FixedSize(180),
                  height: 44,
                  margin: HtmlMargin.only(
                    right: HtmlLength.percent(10),
                    top: HtmlLength.px(8),
                  ),
                  color: Color(0xFFE8F5E9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'margin auto：水平剩余空间分配（居中/靠左/靠右）',
            child: _stack(
              children: const [
                _Block(
                  label: 'left:auto right:auto (center)',
                  width: FixedSize(180),
                  height: 44,
                  margin: HtmlMargin.horizontalAuto(top: HtmlLength.px(8)),
                  color: Color(0xFFE3F2FD),
                ),
                _Block(
                  label: 'left:20 right:auto (left=20)',
                  width: FixedSize(180),
                  height: 44,
                  margin: HtmlMargin.only(
                    left: HtmlLength.px(20),
                    right: HtmlLength.auto(),
                    top: HtmlLength.px(8),
                  ),
                  color: Color(0xFFE8F5E9),
                ),
                _Block(
                  label: 'left:auto right:20 (shift right)',
                  width: FixedSize(180),
                  height: 44,
                  margin: HtmlMargin.only(
                    left: HtmlLength.auto(),
                    right: HtmlLength.px(20),
                    top: HtmlLength.px(8),
                  ),
                  color: Color(0xFFFFF3E0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _section({required String title, required Widget child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      child,
    ],
  );
}

Widget _stack({required List<Widget> children}) {
  return Center(
    child: HtmlDiv(
      width: const FixedSize(320),
      border: HtmlBorder.all(
        width: const FixedBorderWidth(1),
        style: HtmlBorderStyle.solid,
        color: const Color(0x1A000000),
      ),
      background: const HtmlBackground(color: Color(0xFFF7F7F7)),
      children: children,
    ),
  );
}

class _Block extends StatelessWidget {
  final String label;
  final HtmlSize width;
  final double height;
  final HtmlMargin margin;
  final Color color;

  const _Block({
    required this.label,
    this.width = const AutoSize(),
    required this.height,
    required this.margin,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return HtmlDiv(
      margin: margin,
      width: width,
      height: FixedSize(height),
      border: HtmlBorder.all(
        width: const FixedBorderWidth(1),
        style: HtmlBorderStyle.solid,
        color: const Color(0x22000000),
      ),
      background: HtmlBackground(color: color),
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
