import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class TextAlignPage extends StatelessWidget {
  const TextAlignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Align Example')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'TextAlign controls alignment of children similar to CSS text-align.',
              ),
            ),
            _buildSection(
              'Row with TextAlign.center (maps to JustifyContent.center)',
              YogaLayout(
                flexDirection: YGFlexDirection.row,
                textAlign: TextAlign.center,
                width: YogaValue.pct(100),
                height: YogaValue.pt(100),
                children: [
                  _buildBox(Colors.red, 50, 50),
                  _buildBox(Colors.green, 50, 50),
                  _buildBox(Colors.blue, 50, 50),
                ],
              ),
            ),
            _buildSection(
              'Row with TextAlign.right (maps to JustifyContent.flexEnd)',
              YogaLayout(
                flexDirection: YGFlexDirection.row,
                textAlign: TextAlign.right,
                width: YogaValue.pct(100),
                height: YogaValue.pt(100),
                children: [
                  _buildBox(Colors.red, 50, 50),
                  _buildBox(Colors.green, 50, 50),
                  _buildBox(Colors.blue, 50, 50),
                ],
              ),
            ),
            _buildSection(
              'Column with TextAlign.center (maps to AlignItems.center)',
              YogaLayout(
                flexDirection: YGFlexDirection.column,
                textAlign: TextAlign.center,
                width: YogaValue.pct(100),
                height: YogaValue.pt(200),
                children: [
                  _buildBox(Colors.red, 50, 50),
                  _buildBox(Colors.green, 50, 50),
                  _buildBox(Colors.blue, 50, 50),
                ],
              ),
            ),
            _buildSection(
              'Column with TextAlign.right (maps to AlignItems.flexEnd)',
              YogaLayout(
                flexDirection: YGFlexDirection.column,
                textAlign: TextAlign.right,
                width: YogaValue.pct(100),
                height: YogaValue.pt(200),
                children: [
                  _buildBox(Colors.red, 50, 50),
                  _buildBox(Colors.green, 50, 50),
                  _buildBox(Colors.blue, 50, 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(color: Colors.grey[300], child: content),
        const Divider(),
      ],
    );
  }

  Widget _buildBox(Color color, double width, double height) {
    return YogaLayout(
      width: YogaValue.pt(width),
      height: YogaValue.pt(height),
      children: [Container(color: color, width: width, height: height)],
    );
  }
}
