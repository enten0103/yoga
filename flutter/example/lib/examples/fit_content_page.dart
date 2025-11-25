import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class FitContentPage extends StatelessWidget {
  const FitContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fit Content Example')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Block Layout - Width: Auto (Default)',
              YogaLayout(
                display: YogaDisplay.block,
                children: [
                  YogaItem(
                    child: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Should stretch to full width',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              'Block Layout - Width: Fit-Content',
              YogaLayout(
                display: YogaDisplay.block,
                children: [
                  YogaItem(
                    width: const YogaValue.fitContent(),
                    child: Container(
                      color: Colors.green,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Should shrink to text width',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              'Block Layout - Width: Fit-Content (Long Text)',
              YogaLayout(
                display: YogaDisplay.block,
                children: [
                  YogaItem(
                    width: const YogaValue.fitContent(),
                    child: Container(
                      color: Colors.blue,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Should wrap and not exceed parent width. This text is long enough to wrap.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              'Block Layout - Width: Max-Content',
              YogaLayout(
                display: YogaDisplay.block,
                children: [
                  YogaItem(
                    width: const YogaValue.maxContent(),
                    child: Container(
                      color: Colors.orange,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Should be as wide as content without wrapping',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              'Block Layout - Width: Min-Content',
              YogaLayout(
                display: YogaDisplay.block,
                children: [
                  YogaItem(
                    width: const YogaValue.minContent(),
                    child: Container(
                      color: Colors.purple,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Should wrap as much as possible',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              'Centering with Fit-Content + Margin Auto',
              YogaLayout(
                display: YogaDisplay.block,
                children: [
                  YogaItem(
                    width: const YogaValue.fitContent(),
                    margin: const YogaEdgeInsets.symmetric(
                      horizontal: YogaValue.auto(),
                    ),
                    child: Container(
                      color: Colors.teal,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Centered!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            width: 300, // Fixed width container
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.grey),
            ),
            child: content,
          ),
        ],
      ),
    );
  }
}
