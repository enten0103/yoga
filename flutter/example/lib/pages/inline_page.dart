import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

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
