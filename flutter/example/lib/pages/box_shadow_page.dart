import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class BoxShadowPage extends StatelessWidget {
  const BoxShadowPage({super.key});

  static const String _asset = 'assets/test1.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv Box-Shadow 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            title: '基础：单个外阴影',
            child: _demo(
              label: 'offset(0,8) blur 18 spread 0',
              background: const HtmlBackground(color: Color(0xFFFFFFFF)),
              borderRadius: const HtmlBorderRadius.all(Radius.circular(12)),
              boxShadow: const [
                HtmlBoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 8),
                  blurRadius: 18,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: '组合：多重外阴影',
            child: _demo(
              label: '两层 shadow',
              background: const HtmlBackground(color: Color(0xFFFDFDFD)),
              borderRadius: const HtmlBorderRadius.all(Radius.circular(16)),
              boxShadow: const [
                HtmlBoxShadow(
                  color: Color(0x22000000),
                  offset: Offset(0, 12),
                  blurRadius: 24,
                ),
                HtmlBoxShadow(
                  color: Color(0x14000000),
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'spread：扩张阴影区域',
            child: Row(
              children: [
                Expanded(
                  child: _demo(
                    label: 'spread 0',
                    height: 90,
                    background: const HtmlBackground(color: Color(0xFFFFFFFF)),
                    borderRadius: const HtmlBorderRadius.all(
                      Radius.circular(14),
                    ),
                    boxShadow: const [
                      HtmlBoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(0, 6),
                        blurRadius: 14,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _demo(
                    label: 'spread 6',
                    height: 90,
                    background: const HtmlBackground(color: Color(0xFFFFFFFF)),
                    borderRadius: const HtmlBorderRadius.all(
                      Radius.circular(14),
                    ),
                    boxShadow: const [
                      HtmlBoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(0, 6),
                        blurRadius: 14,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: '百分比 offset：相对盒子宽高',
            child: _demo(
              label: 'offsetPercent(dx: 10%, dy: 12%)',
              height: 110,
              background: const HtmlBackground(
                image: HtmlBackgroundImage(
                  image: AssetImage(_asset),
                  repeatX: HtmlBackgroundRepeat.repeat,
                  repeatY: HtmlBackgroundRepeat.repeat,
                  size: HtmlBackgroundSize.auto(),
                  position: HtmlBackgroundPosition(
                    alignment: Alignment.topLeft,
                    offset: Offset.zero,
                  ),
                ),
              ),
              borderRadius: const HtmlBorderRadius.all(Radius.circular(12)),
              boxShadow: const [
                HtmlBoxShadow(
                  color: Color(0x33000000),
                  offsetPercent: Offset(10, 12),
                  blurRadius: 18,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'inset：内阴影（近似）',
            child: Row(
              children: [
                Expanded(
                  child: _demo(
                    label: 'inset + offset(0,6) blur 14',
                    height: 110,
                    background: const HtmlBackground(color: Color(0xFFE3F2FD)),
                    borderRadius: const HtmlBorderRadius.all(
                      Radius.circular(18),
                    ),
                    boxShadow: const [
                      HtmlBoxShadow(
                        inset: true,
                        color: Color(0x55000000),
                        offset: Offset(0, 6),
                        blurRadius: 14,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _demo(
                    label: 'outer + inset 叠加',
                    height: 110,
                    background: const HtmlBackground(color: Color(0xFFFFF8E1)),
                    borderRadius: const HtmlBorderRadius.all(
                      Radius.circular(18),
                    ),
                    boxShadow: const [
                      HtmlBoxShadow(
                        color: Color(0x26000000),
                        offset: Offset(0, 10),
                        blurRadius: 22,
                      ),
                      HtmlBoxShadow(
                        inset: true,
                        color: Color(0x44000000),
                        offset: Offset(0, 6),
                        blurRadius: 14,
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

Widget _demo({
  required String label,
  HtmlBackground? background,
  List<HtmlBoxShadow> boxShadow = const <HtmlBoxShadow>[],
  HtmlBorderRadius? borderRadius,
  double width = 260,
  double height = 100,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 6),
      Center(
        child: HtmlDiv(
          width: FixedSize(width),
          height: FixedSize(height),
          background: background,
          borderRadius: borderRadius,
          boxShadow: boxShadow,
          border: HtmlBorder.all(
            width: const FixedBorderWidth(1),
            style: HtmlBorderStyle.solid,
            color: const Color(0x1A000000),
          ),
        ),
      ),
    ],
  );
}
