import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class IntrinsicSizingPage extends StatelessWidget {
  const IntrinsicSizingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intrinsic Sizing')),
      body: SingleChildScrollView(
        child: YogaLayout(
          width: YogaValue.percent(100),
          height: YogaValue.auto(),
          flexDirection: YGFlexDirection.column,
          padding: YogaEdgeInsets.all(YogaValue.point(20)),
          children: [
            _buildSection(
              title: 'Width: max-content',
              description:
                  'The box should be as wide as its content requires, without wrapping if possible.',
              width: YogaValue.maxContent(),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Width: min-content',
              description:
                  'The box should be as narrow as possible, wrapping text at every opportunity.',
              width: YogaValue.minContent(),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Width: fit-content',
              description:
                  'The box should use available space but not exceed max-content.',
              width: YogaValue.fitContent(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Comparison in a constrained container (width: 200px):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: YogaLayout(
                width: YogaValue.point(200),
                flexDirection: YGFlexDirection.column,
                children: [
                  _buildBox(
                    'max-content (overflows)',
                    YogaValue.maxContent(),
                    Colors.red.shade100,
                  ),
                  const SizedBox(height: 10),
                  _buildBox(
                    'min-content',
                    YogaValue.minContent(),
                    Colors.green.shade100,
                  ),
                  const SizedBox(height: 10),
                  _buildBox(
                    'fit-content',
                    YogaValue.fitContent(),
                    Colors.blue.shade100,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required YogaValue width,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          color: Colors.grey.shade200,
          child: YogaLayout(
            width: YogaValue.percent(100), // Container width
            alignItems: YGAlign.flexStart,
            children: [
              YogaLayout(
                width: width,
                padding: YogaEdgeInsets.all(YogaValue.point(10)),
                background: YogaBackground(color: Colors.blue.shade200),
                children: [
                  Text(
                    'This is some text content to test intrinsic sizing.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBox(String label, YogaValue width, Color color) {
    return YogaLayout(
      width: width,
      padding: YogaEdgeInsets.all(YogaValue.point(5)),
      background: YogaBackground(color: color),
      children: [
        Text(
          'Content for $label',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
