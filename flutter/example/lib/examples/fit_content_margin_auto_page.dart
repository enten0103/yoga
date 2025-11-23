import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class FitContentMarginAutoPage extends StatelessWidget {
  const FitContentMarginAutoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fit Content & Margin Auto')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'This example demonstrates how fit-content (and other intrinsic sizes) '
                'interact with margin: auto to achieve centering.\n\n'
                'Note: For margin: auto to center an item, the item must have a defined width '
                '(like fit-content) and not be stretched by the parent.',
              ),
            ),
            _buildSection(
              title: 'Width: fit-content + Margin: auto',
              description: 'The blue box should be centered horizontally.',
              child: YogaLayout(
                width: YogaValue.percent(100),
                height: YogaValue.point(100),
                background: YogaBackground(color: Colors.grey.shade200),
                children: [
                  YogaLayout(
                    width: YogaValue.fitContent(),
                    margin: YogaEdgeInsets.symmetric(
                      horizontal: YogaValue.auto(),
                    ),
                    padding: YogaEdgeInsets.all(YogaValue.point(10)),
                    background: YogaBackground(color: Colors.blue),
                    children: [
                      const Text(
                        'Centered Box',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildSection(
              title: 'Width: max-content + Margin: auto',
              description: 'The green box should be centered horizontally.',
              child: YogaLayout(
                width: YogaValue.percent(100),
                height: YogaValue.point(100),
                background: YogaBackground(color: Colors.grey.shade200),
                children: [
                  YogaLayout(
                    width: YogaValue.maxContent(),
                    margin: YogaEdgeInsets.symmetric(
                      horizontal: YogaValue.auto(),
                    ),
                    padding: YogaEdgeInsets.all(YogaValue.point(10)),
                    background: YogaBackground(color: Colors.green),
                    children: [
                      const Text(
                        'Centered Max Content',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildSection(
              title: 'Width: min-content + Margin: auto',
              description: 'The red box should be centered horizontally.',
              child: YogaLayout(
                width: YogaValue.percent(100),
                height: YogaValue.point(100),
                background: YogaBackground(color: Colors.grey.shade200),
                children: [
                  YogaLayout(
                    width: YogaValue.minContent(),
                    margin: YogaEdgeInsets.symmetric(
                      horizontal: YogaValue.auto(),
                    ),
                    padding: YogaEdgeInsets.all(YogaValue.point(10)),
                    background: YogaBackground(color: Colors.red),
                    children: [
                      const Text(
                        'Centered Min Content',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildSection(
              title: 'Comparison: No Margin Auto (Default)',
              description: 'The box aligns to start (default).',
              child: YogaLayout(
                width: YogaValue.percent(100),
                height: YogaValue.point(100),
                background: YogaBackground(color: Colors.grey.shade200),
                children: [
                  YogaLayout(
                    width: YogaValue.fitContent(),
                    padding: YogaEdgeInsets.all(YogaValue.point(10)),
                    background: YogaBackground(color: Colors.orange),
                    children: [
                      const Text(
                        'Not Centered',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
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
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
