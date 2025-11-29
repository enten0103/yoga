import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class BasicLayoutPage extends StatefulWidget {
  const BasicLayoutPage({super.key});

  @override
  State<BasicLayoutPage> createState() => _BasicLayoutPageState();
}

class _BasicLayoutPageState extends State<BasicLayoutPage> {
  int _flexDirection = YGFlexDirection.column;
  int _justifyContent = YGJustify.flexStart;
  int _alignItems = YGAlign.stretch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基础布局 (Basic Layout)')),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: YogaLayout(
                display: YogaDisplay.flex,
                flexDirection: _flexDirection,
                justifyContent: _justifyContent,
                alignItems: _alignItems,
                padding: const YogaEdgeInsets.all(YogaValue.point(10)),
                children: [
                  _buildBox(Colors.red, "1", 50, 50),
                  _buildBox(Colors.green, "2", 70, 70),
                  _buildBox(Colors.blue, "3", 50, 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(Color color, String text, double w, double h) {
    return YogaItem(
      width: YogaValue.pt(w),
      height: YogaValue.pt(h),
      child: Container(
        color: color,
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildDropdown<int>(
            "主轴方向 (Flex Direction)",
            _flexDirection,
            {
              "Column (垂直)": YGFlexDirection.column,
              "Row (水平)": YGFlexDirection.row,
              "Column Reverse (垂直反向)": YGFlexDirection.columnReverse,
              "Row Reverse (水平反向)": YGFlexDirection.rowReverse,
            },
            (val) => setState(() => _flexDirection = val!),
          ),
          _buildDropdown<int>(
            "主轴对齐 (Justify Content)",
            _justifyContent,
            {
              "Flex Start (起点)": YGJustify.flexStart,
              "Center (居中)": YGJustify.center,
              "Flex End (终点)": YGJustify.flexEnd,
              "Space Between (两端对齐)": YGJustify.spaceBetween,
              "Space Around (环绕对齐)": YGJustify.spaceAround,
              "Space Evenly (均匀对齐)": YGJustify.spaceEvenly,
            },
            (val) => setState(() => _justifyContent = val!),
          ),
          _buildDropdown<int>(
            "交叉轴对齐 (Align Items)",
            _alignItems,
            {
              "Stretch (拉伸)": YGAlign.stretch,
              "Flex Start (起点)": YGAlign.flexStart,
              "Center (居中)": YGAlign.center,
              "Flex End (终点)": YGAlign.flexEnd,
              "Baseline (基线)": YGAlign.baseline,
            },
            (val) => setState(() => _alignItems = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T value,
    Map<String, T> items,
    ValueChanged<T?> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          items: items.entries.map((e) {
            return DropdownMenuItem<T>(value: e.value, child: Text(e.key));
          }).toList(),
        ),
      ],
    );
  }
}
