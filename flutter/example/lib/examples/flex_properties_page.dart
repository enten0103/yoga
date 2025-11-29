import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class FlexPropertiesPage extends StatefulWidget {
  const FlexPropertiesPage({super.key});

  @override
  State<FlexPropertiesPage> createState() => _FlexPropertiesPageState();
}

class _FlexPropertiesPageState extends State<FlexPropertiesPage> {
  double _flexGrow = 0;
  double _flexShrink = 1;
  double _flexBasis = 100; // Default basis

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flex 属性 (Flex Properties)')),
      body: Column(
        children: [
          _buildControls(),
          const Divider(),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: YogaLayout(
                display: YogaDisplay.flex,
                flexDirection: YGFlexDirection.row,
                alignItems: YGAlign.center,
                padding: const YogaEdgeInsets.all(YogaValue.point(10)),
                children: [
                  // Fixed Item
                  YogaItem(
                    width: YogaValue.pt(80),
                    height: YogaValue.pt(80),
                    child: Container(
                      color: Colors.red,
                      child: const Center(child: Text("固定\n80px")),
                    ),
                  ),
                  // Dynamic Item
                  YogaItem(
                    flexGrow: _flexGrow,
                    flexShrink: _flexShrink,
                    flexBasis: _flexBasis,
                    height: YogaValue.pt(80),
                    margin: const YogaEdgeInsets.symmetric(
                      horizontal: YogaValue.point(5),
                    ),
                    child: Container(
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          "目标\nGrow: ${_flexGrow.toStringAsFixed(1)}\nShrink: ${_flexShrink.toStringAsFixed(1)}\nBasis: ${_flexBasis.toInt()}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Fixed Item
                  YogaItem(
                    width: YogaValue.pt(80),
                    height: YogaValue.pt(80),
                    child: Container(
                      color: Colors.green,
                      child: const Center(child: Text("固定\n80px")),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSlider(
            "放大比例 (Flex Grow)",
            _flexGrow,
            0,
            5,
            (val) => setState(() => _flexGrow = val),
          ),
          _buildSlider(
            "缩小比例 (Flex Shrink)",
            _flexShrink,
            0,
            5,
            (val) => setState(() => _flexShrink = val),
          ),
          _buildSlider(
            "基准值 (Flex Basis)",
            _flexBasis,
            50,
            300,
            (val) => setState(() => _flexBasis = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min) ~/ 0.5,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(1))),
      ],
    );
  }
}
