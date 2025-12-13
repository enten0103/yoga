import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class MinMaxSizePage extends StatelessWidget {
  const MinMaxSizePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv Min/Max Size 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            title: 'min-width：小内容被撑大',
            child: _demoFrame(
              child: HtmlDiv(
                width: const FixedSize(60),
                height: const FixedSize(44),
                minWidth: const FixedSize(160),
                border: HtmlBorder.all(
                  width: const FixedBorderWidth(1),
                  style: HtmlBorderStyle.solid,
                  color: const Color(0x33000000),
                ),
                background: const HtmlBackground(color: Color(0xFFE3F2FD)),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('width=60, minWidth=160'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'max-width：大内容被压小',
            child: _demoFrame(
              child: HtmlDiv(
                width: const FixedSize(260),
                height: const FixedSize(44),
                maxWidth: const FixedSize(140),
                border: HtmlBorder.all(
                  width: const FixedBorderWidth(1),
                  style: HtmlBorderStyle.solid,
                  color: const Color(0x33000000),
                ),
                background: const HtmlBackground(color: Color(0xFFFFF3E0)),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('width=260, maxWidth=140'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'min-height / max-height：高度 clamp',
            child: _demoFrame(
              child: HtmlDiv(
                width: const FixedSize(260),
                height: const FixedSize(180),
                minHeight: const FixedSize(120),
                maxHeight: const FixedSize(140),
                border: HtmlBorder.all(
                  width: const FixedBorderWidth(1),
                  style: HtmlBorderStyle.solid,
                  color: const Color(0x33000000),
                ),
                background: const HtmlBackground(color: Color(0xFFE8F5E9)),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('height=180, minHeight=120, maxHeight=140'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'content-box：min-width 作用于 content，border 额外叠加',
            child: _demoFrame(
              child: HtmlDiv(
                width: const FixedSize(60),
                height: const FixedSize(44),
                boxSizing: HtmlBoxSizing.contentBox,
                minWidth: const FixedSize(120),
                border: HtmlBorder.all(
                  width: const FixedBorderWidth(10),
                  style: HtmlBorderStyle.solid,
                  color: const Color(0xFF212121),
                ),
                background: const HtmlBackground(color: Color(0xFFF3E5F5)),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('contentBox + border(10) + minWidth=120'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'percent min/max：相对包含块（父约束有界时）',
            child: _demoFrame(
              frameWidth: 320,
              child: HtmlDiv(
                width: const PercentSize(80),
                height: const FixedSize(44),
                minWidth: const PercentSize(60),
                maxWidth: const PercentSize(70),
                border: HtmlBorder.all(
                  width: const FixedBorderWidth(1),
                  style: HtmlBorderStyle.solid,
                  color: const Color(0x33000000),
                ),
                background: const HtmlBackground(color: Color(0xFFBBDEFB)),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('width=80%, min=60%, max=70% (of parent)'),
                  ),
                ],
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
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      child,
    ],
  );
}

Widget _demoFrame({required Widget child, double frameWidth = 280}) {
  return Center(
    child: Container(
      width: frameWidth,
      padding: const EdgeInsets.all(10),
      color: const Color(0x0A000000),
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}
