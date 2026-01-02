import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

// Example assets (declared in flutter/example/pubspec.yaml)
const Size _kTest1PixelSize = Size(621, 621);
const ImageProvider _kTest1Asset = AssetImage('assets/test1.png');

class InlineTextAlignPage extends StatelessWidget {
  const InlineTextAlignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inline × TextAlign 实验页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '说明：\n'
            '- 本页专门观察 inline 混排（Text + Image）在 textAlign 下的对齐与换行\n'
            '- 用相同内容对照 start/center/end/justify\n',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          _section(
            title: '单行：内容能放下时的整体对齐（Text + Image）',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mixedSingleLine(align: HtmlTextAlign.start),
                const SizedBox(height: 12),
                _mixedSingleLine(align: HtmlTextAlign.center),
                const SizedBox(height: 12),
                _mixedSingleLine(align: HtmlTextAlign.end),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: '换行：混排内容跨行时每行的对齐效果（Text + Image）',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mixedWrapped(align: HtmlTextAlign.start),
                const SizedBox(height: 12),
                _mixedWrapped(align: HtmlTextAlign.center),
                const SizedBox(height: 12),
                _mixedWrapped(align: HtmlTextAlign.end),
                const SizedBox(height: 12),
                _mixedWrapped(align: HtmlTextAlign.justify),
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
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      child,
    ],
  );
}

Widget _label(HtmlTextAlign align) {
  final String label = switch (align) {
    HtmlTextAlign.start => 'start',
    HtmlTextAlign.center => 'center',
    HtmlTextAlign.end => 'end',
    HtmlTextAlign.justify => 'justify',
  };
  return Text(
    'textAlign: $label',
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  );
}

String _alignKeySuffix(HtmlTextAlign align) {
  return switch (align) {
    HtmlTextAlign.start => 'start',
    HtmlTextAlign.center => 'center',
    HtmlTextAlign.end => 'end',
    HtmlTextAlign.justify => 'justify',
  };
}

Widget _frame({
  Key? key,
  Key? repaintBoundaryKey,
  required double width,
  required HtmlTextAlign align,
  HtmlDisplay display = HtmlDisplay.block,
  required List<Widget> children,
}) {
  final Widget div = HtmlDiv(
    key: key,
    width: FixedSize(width),
    height: const AutoSize(),
    textAlign: align,
    display: display,
    border: HtmlBorder.all(
      width: const FixedBorderWidth(1),
      style: HtmlBorderStyle.solid,
      color: const Color(0x33000000),
    ),
    background: const HtmlBackground(color: Color(0x0A000000)),
    children: children,
  );

  if (repaintBoundaryKey == null) return div;
  return RepaintBoundary(key: repaintBoundaryKey, child: div);
}

Widget _mixedSingleLine({required HtmlTextAlign align}) {
  final String s = _alignKeySuffix(align);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(align),
      const SizedBox(height: 6),
      _frame(
        key: ValueKey('mixedSingleLine.$s.frame'),
        repaintBoundaryKey: ValueKey('mixedSingleLine.$s.rb'),
        width: 320,
        align: align,
        display: HtmlDisplay.inline,
        children: [
          HtmlDiv(
            lineHeight: HtmlLength.px(14),
            display: HtmlDisplay.inline,
            children: [
              HtmlText(
                '轻之国度录入组',
                key: ValueKey('mixedSingleLine.$s.left'),
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
          HtmlText(
            'x',
            key: ValueKey('mixedSingleLine.$s.x'),
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          HtmlDiv(
            lineHeight: HtmlLength.px(22),
            display: HtmlDisplay.inline,
            children: [
              HtmlText(
                '虚空文学旅团',
                key: ValueKey('mixedSingleLine.$s.right'),
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget _mixedWrapped({required HtmlTextAlign align}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(align),
      const SizedBox(height: 6),
      _frame(
        width: 220,
        align: align,
        children: [
          const HtmlText(
            '这是一段较长的文字，用来观察换行后的对齐：',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          HtmlImage(
            image: _kTest1Asset,
            width: const FixedSize(72),
            height: const FixedSize(24),
            naturalPixelSize: _kTest1PixelSize,
            placeholderSize: const Size(1, 1),
            debugLabel: 'img 72×24',
          ),
          const HtmlText(
            ' 图片后继续加一些文字，确保会跨到下一行。',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    ],
  );
}
