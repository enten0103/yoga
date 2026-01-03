import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class HtmlImageNaturalSizeConstraintsPage extends StatelessWidget {
  const HtmlImageNaturalSizeConstraintsPage({super.key});

  static const Size _kWallhavenPixelSize = Size(3840, 2160);
  static const ImageProvider _kWallhavenAsset = AssetImage(
    'assets/wallhaven.png',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlImage natural size × constraints')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '复现目标：声明 naturalPixelSize 后，如果 CSS width/height 被父约束夹紧，'
            '图片的布局高度/宽度仍应按“夹紧后的 used 尺寸”保持比例，而不是用原始 CSS 值推导。',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Text('Case A：width=300(auto height)，父约束 width=120'),
          const SizedBox(height: 8),
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x33000000)),
              ),
              child: SizedBox(
                width: 120,
                child: HtmlImage(
                  key: const ValueKey('caseA'),
                  image: _kWallhavenAsset,
                  width: const FixedSize(300),
                  height: const AutoSize(),
                  naturalPixelSize: _kWallhavenPixelSize,
                  naturalPixelScale: 1.0,
                  placeholderSize: const Size(1, 1),
                  debugLabel: 'A',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Case B：height=240(auto width)，父约束 height=90'),
          const SizedBox(height: 8),
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x33000000)),
              ),
              child: SizedBox(
                height: 90,
                child: HtmlImage(
                  key: const ValueKey('caseB'),
                  image: _kWallhavenAsset,
                  width: const AutoSize(),
                  height: const FixedSize(240),
                  naturalPixelSize: _kWallhavenPixelSize,
                  naturalPixelScale: 1.0,
                  placeholderSize: const Size(1, 1),
                  debugLabel: 'B',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
