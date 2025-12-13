import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class FlexLayoutPage extends StatelessWidget {
  const FlexLayoutPage({super.key});

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
    HtmlSize width = const PercentSize(1),
    HtmlSize height = const FixedSize(96),
  }) {
    return HtmlDiv(
      display: HtmlDisplay.flex,
      width: width,
      height: height,
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

  Widget _tile(String label, {Color? color}) {
    return HtmlDiv(
      display: HtmlDisplay.block,
      width: const FixedSize(72),
      height: const FixedSize(44),
      margin: const HtmlMargin.all(HtmlLength.px(8)),
      background: HtmlBackground(color: color ?? Colors.blueGrey),
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

  Widget _wideTile(
    String label, {
    required Color color,
    double width = 140,
    double height = 44,
    double grow = 0,
    double shrink = 1,
    HtmlLength basis = const HtmlLength.auto(),
    HtmlAlignSelf alignSelf = HtmlAlignSelf.auto,
    HtmlMargin? margin,
  }) {
    return HtmlDiv(
      width: FixedSize(width),
      height: FixedSize(height),
      flexGrow: grow,
      flexShrink: shrink,
      flexBasis: basis,
      alignSelf: alignSelf,
      margin: margin ?? const HtmlMargin.all(HtmlLength.px(8)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv Flex (Yoga) 示例')),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _sectionTitle('justifyContent：spaceBetween + alignItems：center'),
            _frame(
              justifyContent: HtmlJustifyContent.spaceBetween,
              children: [
                _tile('A', color: Colors.teal),
                _tile('B', color: Colors.indigo),
                _tile('C', color: Colors.deepOrange),
              ],
            ),

            _sectionTitle('justifyContent：center / flexEnd'),
            _frame(
              justifyContent: HtmlJustifyContent.center,
              children: [
                _tile('A', color: Colors.teal),
                _tile('B', color: Colors.indigo),
              ],
            ),
            const SizedBox(height: 8),
            _frame(
              justifyContent: HtmlJustifyContent.flexEnd,
              children: [
                _tile('A', color: Colors.teal),
                _tile('B', color: Colors.indigo),
              ],
            ),

            _sectionTitle('flexGrow：中间项扩展'),
            _frame(
              children: [
                _wideTile('L', color: Colors.teal, width: 72),
                _wideTile('Grow=1', color: Colors.indigo, width: 72, grow: 1),
                _wideTile('R', color: Colors.deepOrange, width: 72),
              ],
            ),

            _sectionTitle('flexDirection：column（纵向主轴）'),
            _frame(
              direction: HtmlFlexDirection.column,
              height: const FixedSize(180),
              justifyContent: HtmlJustifyContent.spaceBetween,
              children: [
                _wideTile('Top', color: Colors.teal, width: 200),
                _wideTile('Mid', color: Colors.indigo, width: 200),
                _wideTile('Bottom', color: Colors.deepOrange, width: 200),
              ],
            ),

            _sectionTitle('flexWrap：wrap（多行换行）'),
            _frame(
              wrap: HtmlFlexWrap.wrap,
              height: const FixedSize(200),
              children: [
                _tile('1', color: Colors.teal),
                _tile('2', color: Colors.indigo),
                _tile('3', color: Colors.deepOrange),
                _tile('4', color: Colors.purple),
                _tile('5', color: Colors.blueGrey),
                _tile('6', color: Colors.brown),
                _tile('7', color: Colors.green),
                _tile('8', color: Colors.blue),
              ],
            ),

            _sectionTitle('flexWrap：wrapReverse（反向换行）'),
            _frame(
              wrap: HtmlFlexWrap.wrapReverse,
              height: const FixedSize(200),
              children: [
                _tile('1', color: Colors.teal),
                _tile('2', color: Colors.indigo),
                _tile('3', color: Colors.deepOrange),
                _tile('4', color: Colors.purple),
                _tile('5', color: Colors.blueGrey),
                _tile('6', color: Colors.brown),
                _tile('7', color: Colors.green),
                _tile('8', color: Colors.blue),
              ],
            ),

            _sectionTitle('alignSelf：子项覆盖容器 alignItems'),
            _frame(
              alignItems: HtmlAlignItems.flexStart,
              children: [
                _wideTile('auto', color: Colors.teal, height: 36),
                _wideTile(
                  'alignSelf:flexEnd',
                  color: Colors.indigo,
                  height: 36,
                  alignSelf: HtmlAlignSelf.flexEnd,
                ),
                _wideTile(
                  'alignSelf:stretch',
                  color: Colors.deepOrange,
                  height: 36,
                  alignSelf: HtmlAlignSelf.stretch,
                ),
              ],
            ),

            _sectionTitle('flexBasis + flexShrink：小容器下按比例收缩'),
            _frame(
              width: const FixedSize(260),
              children: [
                _wideTile(
                  'basis=140 shrink=1',
                  color: Colors.teal,
                  width: 140,
                  basis: const HtmlLength.px(140),
                  shrink: 1,
                ),
                _wideTile(
                  'basis=140 shrink=1',
                  color: Colors.indigo,
                  width: 140,
                  basis: const HtmlLength.px(140),
                  shrink: 1,
                ),
                _wideTile(
                  'basis=140 shrink=0',
                  color: Colors.deepOrange,
                  width: 140,
                  basis: const HtmlLength.px(140),
                  shrink: 0,
                ),
              ],
            ),

            _sectionTitle('margin-left/right:auto：子项居中'),
            _frame(
              justifyContent: HtmlJustifyContent.flexStart,
              children: [
                _wideTile(
                  'Centered',
                  color: Colors.indigo,
                  width: 180,
                  margin: const HtmlMargin.horizontalAuto(
                    top: HtmlLength.px(8),
                    bottom: HtmlLength.px(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
