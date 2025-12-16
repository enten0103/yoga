import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class FlexImageInteractionPage extends StatelessWidget {
  const FlexImageInteractionPage({super.key});

  static const String _smallAsset = 'assets/test1.png';
  static const String _largeAsset = 'assets/wallhaven.png';

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  HtmlDiv _frame({
    required List<Widget> children,
    HtmlFlexDirection direction = HtmlFlexDirection.row,
    HtmlJustifyContent justifyContent = HtmlJustifyContent.flexStart,
    HtmlAlignItems alignItems = HtmlAlignItems.center,
    HtmlFlexWrap wrap = HtmlFlexWrap.noWrap,
    HtmlPadding? padding,
    HtmlSize width = const FixedSize(320),
    HtmlSize height = const FixedSize(120),
  }) {
    return HtmlDiv(
      display: HtmlDisplay.flex,
      width: width,
      height: height,
      padding: padding,
      flexDirection: direction,
      justifyContent: justifyContent,
      alignItems: alignItems,
      flexWrap: wrap,
      border: HtmlBorder.all(
        width: const FixedBorderWidth(1),
        style: HtmlBorderStyle.solid,
        color: const Color(0x1A000000),
      ),
      background: HtmlBackground(color: Colors.grey.shade200),
      children: children,
    );
  }

  Widget _imageBox({
    required String label,
    required String asset,
    required BoxFit fit,
    double grow = 0,
    double shrink = 1,
    HtmlLength basis = const HtmlLength.auto(),
    HtmlSize width = const FixedSize(96),
    HtmlSize height = const FixedSize(72),
    Size placeholderSize = const Size(16, 16),
  }) {
    return HtmlDiv(
      width: width,
      height: height,
      flexGrow: grow,
      flexShrink: shrink,
      flexBasis: basis,
      margin: const HtmlMargin.all(HtmlLength.px(8)),
      border: HtmlBorder.all(
        width: const FixedBorderWidth(1),
        style: HtmlBorderStyle.solid,
        color: const Color(0x22000000),
      ),
      background: const HtmlBackground(color: Color(0xFFFFFFFF)),
      children: [
        HtmlImage(
          image: AssetImage(asset),
          fit: fit,
          width: const HtmlLength.percent(100),
          height: const HtmlLength.percent(100),
          debugLabel: label,
          placeholderSize: placeholderSize,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flex × Image 交互示例')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionTitle('1) 固定 item 尺寸下：BoxFit 行为（contain/cover/fill）'),
          Center(
            child: _frame(
              height: const FixedSize(112),
              justifyContent: HtmlJustifyContent.spaceBetween,
              children: [
                _imageBox(
                  label: 'contain',
                  asset: _largeAsset,
                  fit: BoxFit.contain,
                ),
                _imageBox(
                  label: 'cover',
                  asset: _largeAsset,
                  fit: BoxFit.cover,
                ),
                _imageBox(label: 'fill', asset: _largeAsset, fit: BoxFit.fill),
              ],
            ),
          ),

          _sectionTitle('2) flex-grow + flex-basis：图片被约束后的裁切/留白'),
          const Text(
            '对比 basis:auto vs basis:0（类似 CSS flex: 1 1 auto vs 1 1 0）。',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Center(
            child: _frame(
              height: const FixedSize(120),
              alignItems: HtmlAlignItems.stretch,
              children: [
                _imageBox(
                  label: 'grow=1 basis:auto',
                  asset: _smallAsset,
                  fit: BoxFit.cover,
                  grow: 1,
                  basis: const HtmlLength.auto(),
                  width: const AutoSize(),
                  height: const AutoSize(),
                  // test1.png intrinsic size: 621x621
                  placeholderSize: const Size(621, 621),
                ),
                _imageBox(
                  label: 'grow=2 basis:auto',
                  asset: _smallAsset,
                  fit: BoxFit.cover,
                  grow: 2,
                  basis: const HtmlLength.auto(),
                  width: const AutoSize(),
                  height: const AutoSize(),
                  placeholderSize: const Size(621, 621),
                ),
                _imageBox(
                  label: 'grow=1 basis:auto',
                  asset: _smallAsset,
                  fit: BoxFit.cover,
                  grow: 1,
                  basis: const HtmlLength.auto(),
                  width: const AutoSize(),
                  height: const AutoSize(),
                  placeholderSize: const Size(621, 621),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: _frame(
              height: const FixedSize(120),
              alignItems: HtmlAlignItems.stretch,
              children: [
                _imageBox(
                  label: 'grow=1 basis=0',
                  asset: _smallAsset,
                  fit: BoxFit.cover,
                  grow: 1,
                  basis: const HtmlLength.px(0),
                  width: const AutoSize(),
                  height: const AutoSize(),
                ),
                _imageBox(
                  label: 'grow=2 basis=0',
                  asset: _smallAsset,
                  fit: BoxFit.cover,
                  grow: 2,
                  basis: const HtmlLength.px(0),
                  width: const AutoSize(),
                  height: const AutoSize(),
                ),
                _imageBox(
                  label: 'grow=1 basis=0',
                  asset: _smallAsset,
                  fit: BoxFit.cover,
                  grow: 1,
                  basis: const HtmlLength.px(0),
                  width: const AutoSize(),
                  height: const AutoSize(),
                ),
              ],
            ),
          ),

          _sectionTitle('3) wrap：多行换行时图片 item 的尺寸稳定性'),
          Center(
            child: _frame(
              wrap: HtmlFlexWrap.wrap,
              height: const FixedSize(220),
              alignItems: HtmlAlignItems.flexStart,
              children: [
                for (int i = 0; i < 10; i++)
                  _imageBox(
                    label: 'tile ${i + 1}',
                    asset: i.isEven ? _largeAsset : _smallAsset,
                    fit: BoxFit.cover,
                    width: const FixedSize(120),
                    height: const FixedSize(72),
                  ),
              ],
            ),
          ),

          _sectionTitle('4) padding：容器内缩后，图片 item 的可用空间变化'),
          Center(
            child: _frame(
              height: const FixedSize(140),
              padding: const HtmlPadding.all(HtmlLength.px(16)),
              alignItems: HtmlAlignItems.stretch,
              justifyContent: HtmlJustifyContent.spaceBetween,
              children: [
                _imageBox(
                  label: 'stretch + cover',
                  asset: _largeAsset,
                  fit: BoxFit.cover,
                  grow: 1,
                  basis: const HtmlLength.px(0),
                  width: const AutoSize(),
                  height: const AutoSize(),
                ),
                _imageBox(
                  label: 'stretch + contain',
                  asset: _largeAsset,
                  fit: BoxFit.contain,
                  grow: 1,
                  basis: const HtmlLength.px(0),
                  width: const AutoSize(),
                  height: const AutoSize(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
