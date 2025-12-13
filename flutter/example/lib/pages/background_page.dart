import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class BackgroundPage extends StatelessWidget {
  const BackgroundPage({super.key});

  static const String _smallAsset = 'assets/test1.png';
  static const String _largeAsset = 'assets/wallhaven.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv Background 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            title: '基础：background-color',
            child: Row(
              children: [
                Expanded(
                  child: _demo(
                    label: '纯色背景 + border-box clip',
                    background: const HtmlBackground(color: Color(0xFFB2DFDB)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _demo(
                    label: 'padding-box clip (不涂 border 区)',
                    borderWidth: 14,
                    background: const HtmlBackground(
                      color: Color(0xFFE1BEE7),
                      clip: HtmlBackgroundClip.paddingBox,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: '小图 test1.png：repeat/no-repeat/position',
            child: Column(
              children: [
                _demo(
                  label: 'repeat / auto(使用图片原始尺寸)',
                  height: 90,
                  background: const HtmlBackground(
                    image: HtmlBackgroundImage(
                      image: AssetImage(_smallAsset),
                      repeatX: HtmlBackgroundRepeat.repeat,
                      repeatY: HtmlBackgroundRepeat.repeat,
                      size: HtmlBackgroundSize.auto(),
                      position: HtmlBackgroundPosition(
                        alignment: Alignment.topLeft,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _demo(
                  label: 'no-repeat / center + offset(8, 4)',
                  height: 90,
                  background: const HtmlBackground(
                    image: HtmlBackgroundImage(
                      image: AssetImage(_smallAsset),
                      repeatX: HtmlBackgroundRepeat.noRepeat,
                      repeatY: HtmlBackgroundRepeat.noRepeat,
                      size: HtmlBackgroundSize.auto(),
                      position: HtmlBackgroundPosition(
                        alignment: Alignment.center,
                        offset: HtmlLengthOffset(
                          dx: HtmlLength.px(8),
                          dy: HtmlLength.px(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _demo(
                  label: 'repeatX: space / repeatY: round (explicit 18x18)',
                  height: 90,
                  background: const HtmlBackground(
                    image: HtmlBackgroundImage(
                      image: AssetImage(_smallAsset),
                      repeatX: HtmlBackgroundRepeat.space,
                      repeatY: HtmlBackgroundRepeat.round,
                      size: HtmlBackgroundSize.explicit(
                        width: HtmlLength.px(18),
                        height: HtmlLength.px(18),
                      ),
                      position: HtmlBackgroundPosition(
                        alignment: Alignment.topLeft,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: '大图 wallhaven.png：contain/cover/explicit',
            child: Column(
              children: [
                _demo(
                  label: 'contain + no-repeat',
                  height: 120,
                  background: const HtmlBackground(
                    color: Color(0x11000000),
                    image: HtmlBackgroundImage(
                      image: AssetImage(_largeAsset),
                      repeatX: HtmlBackgroundRepeat.noRepeat,
                      repeatY: HtmlBackgroundRepeat.noRepeat,
                      size: HtmlBackgroundSize.contain(),
                      position: HtmlBackgroundPosition(
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _demo(
                  label: 'cover + no-repeat',
                  height: 120,
                  background: const HtmlBackground(
                    image: HtmlBackgroundImage(
                      image: AssetImage(_largeAsset),
                      repeatX: HtmlBackgroundRepeat.noRepeat,
                      repeatY: HtmlBackgroundRepeat.noRepeat,
                      size: HtmlBackgroundSize.cover(),
                      position: HtmlBackgroundPosition(
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _demo(
                  label: 'explicit(160x60) + center',
                  height: 120,
                  background: const HtmlBackground(
                    image: HtmlBackgroundImage(
                      image: AssetImage(_largeAsset),
                      repeatX: HtmlBackgroundRepeat.noRepeat,
                      repeatY: HtmlBackgroundRepeat.noRepeat,
                      size: HtmlBackgroundSize.explicit(
                        width: HtmlLength.px(160),
                        height: HtmlLength.px(60),
                      ),
                      position: HtmlBackgroundPosition(
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'borderRadius：背景裁剪',
            child: Row(
              children: [
                Expanded(
                  child: _demo(
                    label: 'radius 18 + repeat',
                    height: 110,
                    borderRadius: const HtmlBorderRadius.all(
                      Radius.circular(18),
                    ),
                    background: const HtmlBackground(
                      image: HtmlBackgroundImage(
                        image: AssetImage(_smallAsset),
                        repeatX: HtmlBackgroundRepeat.repeat,
                        repeatY: HtmlBackgroundRepeat.repeat,
                        size: HtmlBackgroundSize.explicit(
                          width: HtmlLength.px(20),
                          height: HtmlLength.px(20),
                        ),
                        position: HtmlBackgroundPosition(
                          alignment: Alignment.topLeft,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _demo(
                    label: 'radius 28 + padding-box clip',
                    height: 110,
                    borderWidth: 14,
                    borderRadius: const HtmlBorderRadius.all(
                      Radius.circular(28),
                    ),
                    background: const HtmlBackground(
                      color: Color(0xFFBBDEFB),
                      clip: HtmlBackgroundClip.paddingBox,
                      image: HtmlBackgroundImage(
                        image: AssetImage(_smallAsset),
                        repeatX: HtmlBackgroundRepeat.repeat,
                        repeatY: HtmlBackgroundRepeat.repeat,
                        size: HtmlBackgroundSize.explicit(
                          width: HtmlLength.px(18),
                          height: HtmlLength.px(18),
                        ),
                        position: HtmlBackgroundPosition(
                          alignment: Alignment.topLeft,
                          offset: HtmlLengthOffset(
                            dx: HtmlLength.px(6),
                            dy: HtmlLength.px(6),
                          ),
                        ),
                      ),
                    ),
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
  double width = 260,
  double height = 100,
  double borderWidth = 10,
  HtmlBorderRadius? borderRadius,
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
          border: HtmlBorder.all(
            width: FixedBorderWidth(borderWidth),
            style: HtmlBorderStyle.solid,
            color: const Color(0xFF212121),
          ),
        ),
      ),
    ],
  );
}
