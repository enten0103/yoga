import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class PaddingPage extends StatelessWidget {
  const PaddingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv Padding 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Section(
            title: 'block：padding 影响子元素起始偏移与可用宽度',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('无 padding'),
                SizedBox(height: 8),
                _BlockContainer(),
                SizedBox(height: 16),
                Text('padding: 24px'),
                SizedBox(height: 8),
                _BlockContainer(padding: HtmlPadding.all(HtmlLength.px(24))),
                SizedBox(height: 16),
                Text('padding: horizontal 10% / vertical 12px'),
                SizedBox(height: 8),
                _BlockContainer(
                  padding: HtmlPadding.symmetric(
                    horizontal: HtmlLength.percent(10),
                    vertical: HtmlLength.px(12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          _Section(
            title: 'flex：容器 padding 会内缩布局区域',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('无 padding'),
                SizedBox(height: 8),
                _FlexFrame(),
                SizedBox(height: 16),
                Text('padding: 16px'),
                SizedBox(height: 8),
                _FlexFrame(padding: HtmlPadding.all(HtmlLength.px(16))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
}

class _BlockContainer extends StatelessWidget {
  final HtmlPadding? padding;

  const _BlockContainer({this.padding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HtmlDiv(
        width: const FixedSize(320),
        height: const FixedSize(140),
        padding: padding,
        border: HtmlBorder.all(
          width: const FixedBorderWidth(2),
          style: HtmlBorderStyle.solid,
          color: const Color(0x22000000),
        ),
        background: const HtmlBackground(color: Color(0xFFF7F7F7)),
        children: const [
          _SmallTile(label: 'Child A', color: Color(0xFF1976D2)),
          _SmallTile(label: 'Child B', color: Color(0xFF2E7D32)),
        ],
      ),
    );
  }
}

class _SmallTile extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallTile({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return HtmlDiv(
      width: const FixedSize(120),
      height: const FixedSize(44),
      margin: const HtmlMargin.only(top: HtmlLength.px(8)),
      border: HtmlBorder.all(
        width: const FixedBorderWidth(1),
        style: HtmlBorderStyle.solid,
        color: const Color(0x22000000),
      ),
      background: HtmlBackground(color: color),
      children: [
        Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _FlexFrame extends StatelessWidget {
  final HtmlPadding? padding;

  const _FlexFrame({this.padding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HtmlDiv(
        display: HtmlDisplay.flex,
        width: const FixedSize(320),
        height: const FixedSize(96),
        padding: padding,
        flexDirection: HtmlFlexDirection.row,
        justifyContent: HtmlJustifyContent.spaceBetween,
        alignItems: HtmlAlignItems.center,
        border: HtmlBorder.all(
          width: const FixedBorderWidth(1),
          style: HtmlBorderStyle.solid,
          color: const Color(0x1A000000),
        ),
        background: const HtmlBackground(color: Color(0xFFF0F0F0)),
        children: const [
          _FlexTile('A', Color(0xFF00897B)),
          _FlexTile('B', Color(0xFF3949AB)),
          _FlexTile('C', Color(0xFFF4511E)),
        ],
      ),
    );
  }
}

class _FlexTile extends StatelessWidget {
  final String label;
  final Color color;

  const _FlexTile(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return HtmlDiv(
      width: const FixedSize(72),
      height: const FixedSize(44),
      margin: const HtmlMargin.all(HtmlLength.px(8)),
      background: HtmlBackground(color: color),
      children: [
        Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
