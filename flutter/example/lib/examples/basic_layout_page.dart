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
      appBar: AppBar(title: const Text('Basic Layout')),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: YogaLayout(
                flexDirection: _flexDirection,
                justifyContent: _justifyContent,
                alignItems: _alignItems,
                padding: const EdgeInsets.all(10),
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
      width: w,
      height: h,
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
            "Flex Direction",
            _flexDirection,
            {
              "Column": YGFlexDirection.column,
              "Row": YGFlexDirection.row,
              "Column Reverse": YGFlexDirection.columnReverse,
              "Row Reverse": YGFlexDirection.rowReverse,
            },
            (val) => setState(() => _flexDirection = val!),
          ),
          _buildDropdown<int>(
            "Justify Content",
            _justifyContent,
            {
              "Flex Start": YGJustify.flexStart,
              "Center": YGJustify.center,
              "Flex End": YGJustify.flexEnd,
              "Space Between": YGJustify.spaceBetween,
              "Space Around": YGJustify.spaceAround,
              "Space Evenly": YGJustify.spaceEvenly,
            },
            (val) => setState(() => _justifyContent = val!),
          ),
          _buildDropdown<int>("Align Items", _alignItems, {
            "Stretch": YGAlign.stretch,
            "Flex Start": YGAlign.flexStart,
            "Center": YGAlign.center,
            "Flex End": YGAlign.flexEnd,
            "Baseline": YGAlign.baseline,
          }, (val) => setState(() => _alignItems = val!)),
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
