import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class BorderImagePage extends StatelessWidget {
  const BorderImagePage({super.key});

  static const String _asset = 'assets/wallhaven.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv Border-Image 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            title: '基础：slice(%) + width(auto) + stretch',
            child: _demo(
              label: 'slice 30% / stretch',
              borderImage: HtmlBorderImage(
                image: const AssetImage(_asset),
                slice: const HtmlBorderImageSlice.all(
                  HtmlBorderImageSliceValue.percent(30),
                  fill: false,
                ),
                width: const HtmlBorderImageSideValues.all(
                  HtmlBorderImageSideValue.auto(),
                ),
                repeatX: HtmlBorderImageRepeat.stretch,
                repeatY: HtmlBorderImageRepeat.stretch,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'fill：绘制中心区域',
            child: Row(
              children: [
                Expanded(
                  child: _demo(
                    label: 'fill: false',
                    borderImage: HtmlBorderImage(
                      image: const AssetImage(_asset),
                      slice: const HtmlBorderImageSlice.all(
                        HtmlBorderImageSliceValue.percent(25),
                        fill: false,
                      ),
                      repeatX: HtmlBorderImageRepeat.stretch,
                      repeatY: HtmlBorderImageRepeat.stretch,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _demo(
                    label: 'fill: true',
                    borderImage: HtmlBorderImage(
                      image: const AssetImage(_asset),
                      slice: const HtmlBorderImageSlice.all(
                        HtmlBorderImageSliceValue.percent(25),
                        fill: true,
                      ),
                      repeatX: HtmlBorderImageRepeat.stretch,
                      repeatY: HtmlBorderImageRepeat.stretch,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'repeat：repeat / round / space / stretch',
            child: Column(
              children: [
                _demo(
                  label: 'repeatX: repeat, repeatY: repeat',
                  height: 90,
                  borderImage: HtmlBorderImage(
                    image: const AssetImage(_asset),
                    slice: const HtmlBorderImageSlice.all(
                      HtmlBorderImageSliceValue.px(24),
                      fill: false,
                    ),
                    repeatX: HtmlBorderImageRepeat.repeat,
                    repeatY: HtmlBorderImageRepeat.repeat,
                  ),
                ),
                const SizedBox(height: 12),
                _demo(
                  label: 'repeatX: round, repeatY: round',
                  height: 90,
                  borderImage: HtmlBorderImage(
                    image: const AssetImage(_asset),
                    slice: const HtmlBorderImageSlice.all(
                      HtmlBorderImageSliceValue.px(24),
                      fill: false,
                    ),
                    repeatX: HtmlBorderImageRepeat.round,
                    repeatY: HtmlBorderImageRepeat.round,
                  ),
                ),
                const SizedBox(height: 12),
                _demo(
                  label: 'repeatX: space, repeatY: space',
                  height: 90,
                  borderImage: HtmlBorderImage(
                    image: const AssetImage(_asset),
                    slice: const HtmlBorderImageSlice.all(
                      HtmlBorderImageSliceValue.px(24),
                      fill: false,
                    ),
                    repeatX: HtmlBorderImageRepeat.space,
                    repeatY: HtmlBorderImageRepeat.space,
                  ),
                ),
                const SizedBox(height: 12),
                _demo(
                  label: 'repeatX: stretch, repeatY: stretch',
                  height: 90,
                  borderImage: HtmlBorderImage(
                    image: const AssetImage(_asset),
                    slice: const HtmlBorderImageSlice.all(
                      HtmlBorderImageSliceValue.px(24),
                      fill: false,
                    ),
                    repeatX: HtmlBorderImageRepeat.stretch,
                    repeatY: HtmlBorderImageRepeat.stretch,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'width：number / px / percent / auto',
            child: Column(
              children: [
                _demo(
                  label: 'width: number(1.0) => 1 * borderWidth',
                  borderWidth: 12,
                  borderImage: HtmlBorderImage(
                    image: const AssetImage(_asset),
                    slice: const HtmlBorderImageSlice.all(
                      HtmlBorderImageSliceValue.percent(20),
                      fill: false,
                    ),
                    width: const HtmlBorderImageSideValues.all(
                      HtmlBorderImageSideValue.number(1.0),
                    ),
                    repeatX: HtmlBorderImageRepeat.repeat,
                    repeatY: HtmlBorderImageRepeat.repeat,
                  ),
                ),
                const SizedBox(height: 12),
                _demo(
                  label: 'width: px(20)',
                  borderWidth: 12,
                  borderImage: HtmlBorderImage(
                    image: const AssetImage(_asset),
                    slice: const HtmlBorderImageSlice.all(
                      HtmlBorderImageSliceValue.percent(20),
                      fill: false,
                    ),
                    width: const HtmlBorderImageSideValues.all(
                      HtmlBorderImageSideValue.px(20),
                    ),
                    repeatX: HtmlBorderImageRepeat.repeat,
                    repeatY: HtmlBorderImageRepeat.repeat,
                  ),
                ),
                const SizedBox(height: 12),
                _demo(
                  label: 'width: percent(15%)',
                  borderWidth: 12,
                  borderImage: HtmlBorderImage(
                    image: const AssetImage(_asset),
                    slice: const HtmlBorderImageSlice.all(
                      HtmlBorderImageSliceValue.percent(20),
                      fill: false,
                    ),
                    width: const HtmlBorderImageSideValues.all(
                      HtmlBorderImageSideValue.percent(15),
                    ),
                    repeatX: HtmlBorderImageRepeat.repeat,
                    repeatY: HtmlBorderImageRepeat.repeat,
                  ),
                ),
                const SizedBox(height: 12),
                _demo(
                  label: 'width: auto => borderWidth',
                  borderWidth: 12,
                  borderImage: HtmlBorderImage(
                    image: const AssetImage(_asset),
                    slice: const HtmlBorderImageSlice.all(
                      HtmlBorderImageSliceValue.percent(20),
                      fill: false,
                    ),
                    width: const HtmlBorderImageSideValues.all(
                      HtmlBorderImageSideValue.auto(),
                    ),
                    repeatX: HtmlBorderImageRepeat.repeat,
                    repeatY: HtmlBorderImageRepeat.repeat,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'outset：向外扩张绘制区域',
            child: Row(
              children: [
                Expanded(
                  child: _demo(
                    label: 'outset: 0',
                    borderWidth: 12,
                    borderImage: HtmlBorderImage(
                      image: const AssetImage(_asset),
                      slice: const HtmlBorderImageSlice.all(
                        HtmlBorderImageSliceValue.percent(25),
                        fill: false,
                      ),
                      outset: const HtmlBorderImageSideValues.all(
                        HtmlBorderImageSideValue.px(0),
                      ),
                      repeatX: HtmlBorderImageRepeat.repeat,
                      repeatY: HtmlBorderImageRepeat.repeat,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _demo(
                    label: 'outset: px(16)',
                    borderWidth: 12,
                    borderImage: HtmlBorderImage(
                      image: const AssetImage(_asset),
                      slice: const HtmlBorderImageSlice.all(
                        HtmlBorderImageSliceValue.percent(25),
                        fill: false,
                      ),
                      outset: const HtmlBorderImageSideValues.all(
                        HtmlBorderImageSideValue.px(16),
                      ),
                      repeatX: HtmlBorderImageRepeat.repeat,
                      repeatY: HtmlBorderImageRepeat.repeat,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'borderRadius：对 border-image 进行裁剪',
            child: Row(
              children: [
                Expanded(
                  child: _demo(
                    label: 'radius: 0',
                    borderImage: HtmlBorderImage(
                      image: const AssetImage(_asset),
                      slice: const HtmlBorderImageSlice.all(
                        HtmlBorderImageSliceValue.px(28),
                        fill: true,
                      ),
                      repeatX: HtmlBorderImageRepeat.round,
                      repeatY: HtmlBorderImageRepeat.round,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _demo(
                    label: 'radius: 18',
                    radius: const HtmlBorderRadius.all(Radius.circular(18)),
                    borderImage: HtmlBorderImage(
                      image: const AssetImage(_asset),
                      slice: const HtmlBorderImageSlice.all(
                        HtmlBorderImageSliceValue.px(28),
                        fill: true,
                      ),
                      repeatX: HtmlBorderImageRepeat.round,
                      repeatY: HtmlBorderImageRepeat.round,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: '对齐 CSS：border-style hidden 时不绘制 border-image',
            child: _demo(
              label: 'border-style: hidden',
              borderWidth: 12,
              border: HtmlBorder.all(
                width: const FixedBorderWidth(12),
                style: HtmlBorderStyle.hidden,
              ),
              borderImage: HtmlBorderImage(
                image: const AssetImage(_asset),
                slice: const HtmlBorderImageSlice.all(
                  HtmlBorderImageSliceValue.percent(25),
                  fill: true,
                ),
                repeatX: HtmlBorderImageRepeat.repeat,
                repeatY: HtmlBorderImageRepeat.repeat,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _demo({
    required String label,
    required HtmlBorderImage borderImage,
    double width = 320,
    double height = 110,
    double borderWidth = 12,
    HtmlBorder? border,
    HtmlBorderRadius? radius,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.all(8),
          child: Center(
            child: HtmlDiv(
              width: FixedSize(width),
              height: FixedSize(height),
              border:
                  border ??
                  HtmlBorder.all(
                    width: FixedBorderWidth(borderWidth),
                    style: HtmlBorderStyle.solid,
                    color: Colors.black,
                    borderImage: borderImage,
                  ),
              borderRadius: radius,
              children: [
                Container(color: Colors.black.withValues(alpha: 0.05)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
