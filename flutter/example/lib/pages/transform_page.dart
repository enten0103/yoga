import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class TransformPage extends StatelessWidget {
  const TransformPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv Transform 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            title: 'rotate：绕中心旋转（不影响布局）',
            child: _demo(
              label: 'rotateZ(15°)',
              transform: HtmlTransform(
                matrix: Matrix4.identity()..rotateZ(15 * math.pi / 180.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'translate：平移（不影响布局）',
            child: _demo(
              label: 'translate(24, 10)',
              transform: HtmlTransform(
                matrix: Matrix4.identity()
                  ..translateByDouble(24.0, 10.0, 0.0, 1.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'scale：缩放 + 自定义 origin（左上）',
            child: _demo(
              label: 'scale(1.2) @ origin topLeft',
              transform: HtmlTransform(
                originAlignment: Alignment.topLeft,
                matrix: Matrix4.identity()..scaleByDouble(1.2, 1.2, 1.0, 1.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'originPercent：用百分比指定 transform-origin',
            child: _demo(
              label: 'originPercent(25%, 75%) + rotateZ(20°)',
              transform: HtmlTransform(
                originAlignment: Alignment.topLeft,
                originOffset: const HtmlLengthOffset(
                  dx: HtmlLength.percent(25),
                  dy: HtmlLength.percent(75),
                ),
                matrix: Matrix4.identity()..rotateZ(20 * math.pi / 180.0),
              ),
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

Widget _demo({required String label, required HtmlTransform transform}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
      ),
      const SizedBox(height: 8),
      Center(
        child: HtmlDiv(
          width: const FixedSize(180),
          height: const FixedSize(90),
          transform: transform,
          borderRadius: const HtmlBorderRadius.all(Radius.circular(12)),
          border: HtmlBorder.all(
            width: const FixedBorderWidth(2),
            style: HtmlBorderStyle.solid,
            color: const Color(0x1A000000),
          ),
          background: const HtmlBackground(color: Color(0xFFFDFDFD)),
          children: const [
            Padding(padding: EdgeInsets.all(12), child: Text('transform demo')),
          ],
        ),
      ),
    ],
  );
}
