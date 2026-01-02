import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

// Example assets (declared in flutter/example/pubspec.yaml)
const Size _kTest1PixelSize = Size(621, 621);
const Size _kWallhavenPixelSize = Size(3840, 2160);

const ImageProvider _kTest1Asset = AssetImage('assets/test1.png');
const ImageProvider _kWallhavenAsset = AssetImage('assets/wallhaven.png');

class InlinePage extends StatelessWidget {
  const InlinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv Inline / Baseline 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '说明：\n'
            '- 子元素 display=inline 会在父容器内按行内流排版并自动换行\n'
            '- 行内元素按 baseline 对齐（当前实现：HtmlDiv baseline=盒子底边）\n'
            '- margin-top/bottom 会参与 line box 的 ascent/descent（近似 CSS 行盒）',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          _section(
            title: '基线对齐：不同高度的 inline 盒子底边对齐',
            child: Stack(
              children: [
                HtmlDiv(
                  width: const FixedSize(300),
                  height: const AutoSize(),
                  border: HtmlBorder.all(
                    width: const FixedBorderWidth(1),
                    style: HtmlBorderStyle.solid,
                    color: const Color(0x33000000),
                  ),
                  background: const HtmlBackground(color: Color(0x0A000000)),
                  children: [
                    // Align with inline_page.html: the HTML demo uses
                    // `.inline-flow { font-size: 0; line-height: 0; }` to
                    // remove font strut so the line box height is driven by
                    // the inline-blocks themselves. Here we do the same by
                    // injecting a zero-metrics text node as the paragraph base.
                    const HtmlText(
                      '',
                      style: TextStyle(fontSize: 0, height: 0),
                    ),
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      width: FixedSize(70),
                      height: FixedSize(40),
                      background: HtmlBackground(color: Color(0xFF90CAF9)),
                      border: HtmlBorder.all(
                        width: FixedBorderWidth(1),
                        style: HtmlBorderStyle.solid,
                        color: Color(0x33000000),
                      ),
                    ),
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      width: FixedSize(110),
                      height: FixedSize(18),
                      background: HtmlBackground(color: Color(0xFFA5D6A7)),
                      border: HtmlBorder.all(
                        width: FixedBorderWidth(1),
                        style: HtmlBorderStyle.solid,
                        color: Color(0x33000000),
                      ),
                    ),
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      width: FixedSize(90),
                      height: FixedSize(28),
                      background: HtmlBackground(color: Color(0xFFFFCC80)),
                      border: HtmlBorder.all(
                        width: FixedBorderWidth(1),
                        style: HtmlBorderStyle.solid,
                        color: Color(0x33000000),
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(height: 1, color: Color(0x66FF0000)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: '换行：宽度不足时自动折行',
            child: HtmlDiv(
              width: const FixedSize(240),
              height: const AutoSize(),
              border: HtmlBorder.all(
                width: const FixedBorderWidth(1),
                style: HtmlBorderStyle.solid,
                color: const Color(0x33000000),
              ),
              background: const HtmlBackground(color: Color(0x0A000000)),
              children: [
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  width: FixedSize(120),
                  height: FixedSize(26),
                  background: HtmlBackground(color: Color(0xFFB39DDB)),
                ),
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  width: FixedSize(120),
                  height: FixedSize(18),
                  background: HtmlBackground(color: Color(0xFF80DEEA)),
                ),
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  width: FixedSize(120),
                  height: FixedSize(34),
                  background: HtmlBackground(color: Color(0xFFFFAB91)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'inline + Text + Image：作为“盒子”参与折行（图片不会被拆分）',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '要点：每个 inline 子节点都是一个盒子（box）。当一行放不下时，整个盒子换到下一行。\n'
                  '- Text: HtmlText 作为一个 inline 盒子（内部可能自换行）\n'
                  '- Image: HtmlImage 是 replaced-like 盒子，宽高可显式指定\n',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    HtmlDiv(
                      width: const FixedSize(280),
                      height: const AutoSize(),
                      border: HtmlBorder.all(
                        width: const FixedBorderWidth(1),
                        style: HtmlBorderStyle.solid,
                        color: const Color(0x33000000),
                      ),
                      background: const HtmlBackground(
                        color: Color(0x0A000000),
                      ),
                      children: [
                        HtmlDiv(
                          display: HtmlDisplay.inline,
                          children: [
                            const HtmlText(
                              '这一段文字很短，后面跟一个图片盒子：',
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                            HtmlImage(
                              image: _kTest1Asset,
                              width: const FixedSize(90),
                              height: const FixedSize(28),
                              naturalPixelSize: _kTest1PixelSize,
                              placeholderSize: const Size(1, 1),
                              debugLabel: 'img 90×28',
                            ),
                            const HtmlText(
                              '再加一点文字，看看是否会把图片/文字整体换到下一行。',
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    HtmlDiv(
                      width: const FixedSize(280),
                      height: const AutoSize(),
                      border: HtmlBorder.all(
                        width: const FixedBorderWidth(1),
                        style: HtmlBorderStyle.solid,
                        color: const Color(0x33000000),
                      ),
                      background: const HtmlBackground(
                        color: Color(0x0A000000),
                      ),
                      children: [
                        HtmlDiv(
                          display: HtmlDisplay.inline,
                          children: [
                            const HtmlText(
                              '当图片盒子放在行尾且放不下时，图片会整体换行：',
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                            HtmlImage(
                              image: _kTest1Asset,
                              width: const FixedSize(140),
                              height: const FixedSize(28),
                              naturalPixelSize: _kTest1PixelSize,
                              placeholderSize: const Size(1, 1),
                              debugLabel: 'img 140×28',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'text-align：start/center/end（Text + Image inline 混排）',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _textAlignMixedExample(align: HtmlTextAlign.start),
                const SizedBox(height: 12),
                _textAlignMixedExample(align: HtmlTextAlign.center),
                const SizedBox(height: 12),
                _textAlignMixedExample(align: HtmlTextAlign.end),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'inline 混排：Text + span + Image（auto 尺寸来自 naturalPixelSize）',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '要点：\n'
                  '- span: 这里用 display=inline 的 HtmlDiv 作为“span-like”包装\n'
                  '- image: 不指定 width/height（auto），由 naturalPixelSize 推导 intrinsic size\n'
                  '- naturalPixelScale: 控制像素到逻辑像素的缩放（类似 @2x 的 scale）\n',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                HtmlDiv(
                  width: const FixedSize(320),
                  height: const AutoSize(),
                  border: HtmlBorder.all(
                    width: const FixedBorderWidth(1),
                    style: HtmlBorderStyle.solid,
                    color: const Color(0x33000000),
                  ),
                  background: const HtmlBackground(color: Color(0x0A000000)),
                  children: [
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      children: [
                        const HtmlText(
                          'prefix ',
                          style: TextStyle(fontSize: 14, height: 1.2),
                        ),
                        HtmlDiv(
                          display: HtmlDisplay.inline,
                          background: const HtmlBackground(
                            color: Color(0x1A2196F3),
                          ),
                          children: const [
                            HtmlText(
                              'span',
                              style: TextStyle(fontSize: 14, height: 1.2),
                            ),
                          ],
                        ),
                        const HtmlText(
                          ' + ',
                          style: TextStyle(fontSize: 14, height: 1.2),
                        ),
                        HtmlImage(
                          image: _kTest1Asset,
                          width: const AutoSize(),
                          height: const AutoSize(),
                          naturalPixelSize: _kTest1PixelSize,
                          // 621px / 6.21 ~= 100 logical px.
                          naturalPixelScale: 6.21,
                          placeholderSize: const Size(1, 1),
                          debugLabel: 'test1 auto (100×100)',
                        ),
                        const HtmlText(
                          ' suffix suffix suffix suffix suffix',
                          style: TextStyle(fontSize: 14, height: 1.2),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                HtmlDiv(
                  width: const FixedSize(320),
                  height: const AutoSize(),
                  border: HtmlBorder.all(
                    width: const FixedBorderWidth(1),
                    style: HtmlBorderStyle.solid,
                    color: const Color(0x33000000),
                  ),
                  background: const HtmlBackground(color: Color(0x0A000000)),
                  children: [
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      children: [
                        const HtmlText(
                          'wallhaven(auto)+text：',
                          style: TextStyle(fontSize: 14, height: 1.2),
                        ),
                        HtmlImage(
                          image: _kWallhavenAsset,
                          width: const AutoSize(),
                          height: const AutoSize(),
                          naturalPixelSize: _kWallhavenPixelSize,
                          // 3840/64=60, 2160/64=33.75.
                          naturalPixelScale: 64,
                          placeholderSize: const Size(1, 1),
                          debugLabel: 'wallhaven auto (~60×33.8)',
                        ),
                        const HtmlText(
                          ' 后面再跟一段文字，验证换行与行高。',
                          style: TextStyle(fontSize: 14, height: 1.2),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'text-indent：只影响第一行（支持 px/%）',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    HtmlDiv(
                      width: const FixedSize(300),
                      height: const AutoSize(),
                      textIndent: const HtmlLength.px(40),
                      border: HtmlBorder.all(
                        width: const FixedBorderWidth(1),
                        style: HtmlBorderStyle.solid,
                        color: const Color(0x33000000),
                      ),
                      background: const HtmlBackground(
                        color: Color(0x0A000000),
                      ),
                      children: [
                        HtmlDiv(
                          display: HtmlDisplay.inline,
                          width: FixedSize(80),
                          height: FixedSize(22),
                          background: HtmlBackground(color: Color(0xFFCE93D8)),
                        ),
                        HtmlDiv(
                          display: HtmlDisplay.inline,
                          width: FixedSize(120),
                          height: FixedSize(22),
                          background: HtmlBackground(color: Color(0xFF90CAF9)),
                        ),
                        HtmlDiv(
                          display: HtmlDisplay.inline,
                          width: FixedSize(120),
                          height: FixedSize(22),
                          background: HtmlBackground(color: Color(0xFFA5D6A7)),
                        ),
                      ],
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Container(
                              width: 1,
                              height: 200,
                              color: Color(0x66FF0000),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    HtmlDiv(
                      width: const FixedSize(300),
                      height: const AutoSize(),
                      textIndent: const HtmlLength.percent(10),
                      textAlign: HtmlTextAlign.center,
                      border: HtmlBorder.all(
                        width: const FixedBorderWidth(1),
                        style: HtmlBorderStyle.solid,
                        color: const Color(0x33000000),
                      ),
                      background: const HtmlBackground(
                        color: Color(0x0A000000),
                      ),
                      children: [
                        HtmlDiv(
                          display: HtmlDisplay.inline,
                          width: FixedSize(90),
                          height: FixedSize(22),
                          background: HtmlBackground(color: Color(0xFFFFCC80)),
                        ),
                        HtmlDiv(
                          display: HtmlDisplay.inline,
                          width: FixedSize(90),
                          height: FixedSize(22),
                          background: HtmlBackground(color: Color(0xFFB2DFDB)),
                        ),
                      ],
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Container(
                              width: 1,
                              height: 200,
                              color: Color(0x66FF0000),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'inline + FitContent：受可用宽度影响（内部可换行）',
            child: HtmlDiv(
              width: const FixedSize(300),
              height: const AutoSize(),
              border: HtmlBorder.all(
                width: const FixedBorderWidth(1),
                style: HtmlBorderStyle.solid,
                color: const Color(0x33000000),
              ),
              background: const HtmlBackground(color: Color(0x0A000000)),
              children: [
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  width: FitContent(),
                  height: AutoSize(),
                  border: HtmlBorder.all(
                    width: const FixedBorderWidth(1),
                    style: HtmlBorderStyle.solid,
                    color: const Color(0x66000000),
                  ),
                  background: const HtmlBackground(color: Color(0x14FF0000)),
                  children: [
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      width: FixedSize(200),
                      height: FixedSize(22),
                      background: HtmlBackground(color: Color(0xFF90CAF9)),
                    ),
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      width: FixedSize(200),
                      height: FixedSize(22),
                      background: HtmlBackground(color: Color(0xFFA5D6A7)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'inline 嵌套与 inline 中嵌套 block',
            child: HtmlDiv(
              width: const FixedSize(300),
              height: const AutoSize(),
              border: HtmlBorder.all(
                width: const FixedBorderWidth(1),
                style: HtmlBorderStyle.solid,
                color: const Color(0x33000000),
              ),
              background: const HtmlBackground(color: Color(0x0A000000)),
              children: [
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  width: AutoSize(),
                  height: AutoSize(),
                  border: HtmlBorder.all(
                    width: const FixedBorderWidth(1),
                    style: HtmlBorderStyle.solid,
                    color: const Color(0x66000000),
                  ),
                  background: const HtmlBackground(color: Color(0x140000FF)),
                  children: [
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      width: AutoSize(),
                      height: AutoSize(),
                      children: [
                        HtmlDiv(
                          display: HtmlDisplay.inline,
                          width: FixedSize(60),
                          height: FixedSize(20),
                          background: HtmlBackground(color: Color(0xFFFFCC80)),
                        ),
                        HtmlDiv(
                          display: HtmlDisplay.inline,
                          width: FixedSize(50),
                          height: FixedSize(20),
                          background: HtmlBackground(color: Color(0xFFB2DFDB)),
                        ),
                      ],
                    ),
                    HtmlDiv(
                      display: HtmlDisplay.block,
                      width: FixedSize(220),
                      height: FixedSize(26),
                      background: HtmlBackground(color: Color(0xFFCE93D8)),
                    ),
                    HtmlDiv(
                      display: HtmlDisplay.inline,
                      width: FixedSize(80),
                      height: FixedSize(20),
                      background: HtmlBackground(color: Color(0xFF80DEEA)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'inline + margin-top/bottom（影响行盒高度）',
            child: HtmlDiv(
              width: const FixedSize(300),
              height: const AutoSize(),
              border: HtmlBorder.all(
                width: const FixedBorderWidth(1),
                style: HtmlBorderStyle.solid,
                color: const Color(0x33000000),
              ),
              background: const HtmlBackground(color: Color(0x0A000000)),
              children: [
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  width: FixedSize(90),
                  height: FixedSize(22),
                  margin: HtmlMargin.only(
                    top: HtmlLength.px(10),
                    bottom: HtmlLength.px(6),
                  ),
                  background: HtmlBackground(color: Color(0xFFFFF59D)),
                ),
                HtmlDiv(
                  display: HtmlDisplay.inline,
                  width: FixedSize(140),
                  height: FixedSize(22),
                  background: HtmlBackground(color: Color(0xFFB2DFDB)),
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
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      child,
    ],
  );
}

Widget _textAlignMixedExample({required HtmlTextAlign align}) {
  final String label = switch (align) {
    HtmlTextAlign.start => 'start',
    HtmlTextAlign.center => 'center',
    HtmlTextAlign.end => 'end',
    HtmlTextAlign.justify => 'justify',
  };

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'textAlign: $label',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      HtmlDiv(
        width: const FixedSize(320),
        height: const AutoSize(),
        textAlign: align,
        border: HtmlBorder.all(
          width: const FixedBorderWidth(1),
          style: HtmlBorderStyle.solid,
          color: const Color(0x33000000),
        ),
        background: const HtmlBackground(color: Color(0x0A000000)),
        children: [
          HtmlDiv(
            display: HtmlDisplay.inline,
            children: [
              const HtmlText(
                '这是一段较长的文字，用来观察 text-align 在换行后的对齐效果：',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              HtmlImage(
                image: _kTest1Asset,
                width: const FixedSize(72),
                height: const FixedSize(24),
                naturalPixelSize: _kTest1PixelSize,
                placeholderSize: const Size(1, 1),
                debugLabel: 'img',
              ),
              const HtmlText(
                '图片后面继续追加一些文字，确保内容会换到下一行。',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
