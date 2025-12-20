import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class JianjiePage extends StatelessWidget {
  const JianjiePage({super.key});

  static const String _p1 =
      '学期末的脚步渐渐逼近。伽耶即将参加入学考试，我们则要面对音乐祭的最后准备工作。这时，因为华园老师以前参加的管弦乐团因为人手不足，PNO的成员被找去帮忙。然而音乐会偏偏定在情人节举行！来自所有成员的巧克力总攻击让我应接不暇。';

  static const String _p2 =
      '可是这段甜蜜的时光并不长久。为了拯救处于解散危机的管弦乐团，我决定邀请他们参加音乐祭。一定要用无懈可击的演奏来宣示乐团的复苏！';

  static const String _p3 = '激情四溢的恋爱合奏，超高纯度青春故事，第四集！';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('简介（复刻）')),
      body: HtmlDiv(
        // Mimic a simple document page.
        padding: const HtmlPadding.symmetric(
          horizontal: HtmlLength.px(24),
          vertical: HtmlLength.px(16),
        ),
        children: [
          HtmlDiv(
            maxWidth: FitContent(),
            margin: const HtmlMargin.only(
              left: HtmlLength.auto(),
              right: HtmlLength.auto(),
            ),
            padding: HtmlPadding.only(
              left: HtmlLength.px(16),
              right: HtmlLength.px(16),
              top: HtmlLength.px(12),
            ),
            children: const [
              HtmlDiv(
                lineHeight: HtmlLength.px(24),
                children: [_TitleBlock('简介')],
              ),
              HtmlDiv(),
              HtmlDiv(
                lineHeight: HtmlLength.px(24),
                children: [_ParagraphBlock(_p1)],
              ),
              HtmlDiv(
                lineHeight: HtmlLength.px(24),
                children: [_ParagraphBlock(_p2)],
              ),
              HtmlDiv(
                lineHeight: HtmlLength.px(24),
                children: [_EmphasisBlock(_p3)],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final String text;
  const _TitleBlock(this.text);

  @override
  Widget build(BuildContext context) {
    return HtmlDiv(
      display: HtmlDisplay.inline,
      margin: const HtmlMargin.only(bottom: HtmlLength.px(12)),
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ParagraphBlock extends StatelessWidget {
  final String text;
  const _ParagraphBlock(this.text);

  @override
  Widget build(BuildContext context) {
    return HtmlDiv(
      display: HtmlDisplay.inline,
      margin: const HtmlMargin.only(bottom: HtmlLength.px(12)),
      children: [Text(text, style: const TextStyle(fontSize: 16, height: 1.7))],
    );
  }
}

class _EmphasisBlock extends StatelessWidget {
  final String text;
  const _EmphasisBlock(this.text);

  @override
  Widget build(BuildContext context) {
    return HtmlDiv(
      display: HtmlDisplay.inline,
      lineHeight: HtmlLength.px(24),
      margin: const HtmlMargin.only(bottom: HtmlLength.px(12)),
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            height: 1.7,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
