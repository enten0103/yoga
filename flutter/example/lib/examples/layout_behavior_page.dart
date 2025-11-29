import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class LayoutBehaviorPage extends StatelessWidget {
  const LayoutBehaviorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layout Behavior (Block vs Flex)')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '1. Block Layout (Default)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Expectation: Children stack vertically. Parent height = sum of children heights. Parent width = 100% (unless fit-content).',
              ),
            ),
            Container(
              color: Colors.grey[200],
              child: YogaLayout(
                display: YogaDisplay.block, // Explicitly block
                padding: YogaEdgeInsets.all(YogaValue.point(10)),
                background: YogaBackground(color: Colors.grey[300]),
                children: [
                  YogaLayout(
                    children: [YogaItem(child: _buildBox("1", Colors.red))],
                  ),
                  YogaLayout(
                    children: [YogaItem(child: _buildBox("2", Colors.green))],
                  ),
                  YogaLayout(
                    children: [YogaItem(child: _buildBox("3", Colors.blue))],
                  ),
                ],
              ),
            ),

            const Divider(),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '2. Flex Layout (Row)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Expectation: Children arranged horizontally. Parent height = max child height. Children width = content width (auto).',
              ),
            ),
            Container(
              color: Colors.grey[200],
              child: YogaLayout(
                display: YogaDisplay.flex,
                flexDirection: YGFlexDirection.row,
                padding: YogaEdgeInsets.all(YogaValue.point(10)),
                background: YogaBackground(color: Colors.grey[300]),
                children: [
                  YogaLayout(
                    children: [YogaItem(child: _buildBox("1", Colors.red))],
                  ),
                  YogaLayout(
                    children: [YogaItem(child: _buildBox("2", Colors.green))],
                  ),
                  YogaLayout(
                    children: [YogaItem(child: _buildBox("3", Colors.blue))],
                  ),
                ],
              ),
            ),

            const Divider(),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '3. Nested Block in Flex',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Expectation: Flex container (Row). Inside, a Block container. The Block container should have width=content (because it is a flex item) and height=sum of children.',
              ),
            ),
            Container(
              color: Colors.grey[200],
              child: YogaLayout(
                display: YogaDisplay.flex,
                flexDirection: YGFlexDirection.row,
                padding: YogaEdgeInsets.all(YogaValue.point(10)),
                background: YogaBackground(color: Colors.grey[300]),
                children: [
                  YogaLayout(
                    display: YogaDisplay.block,
                    borderWidth: const EdgeInsets.all(1),
                    children: [
                      YogaLayout(
                        children: [
                          YogaItem(child: _buildBox("A1", Colors.orange)),
                        ],
                      ),
                      YogaLayout(
                        children: [
                          YogaItem(child: _buildBox("A2", Colors.orange)),
                        ],
                      ),
                    ],
                  ),
                  YogaLayout(
                    display: YogaDisplay.block,
                    borderWidth: const EdgeInsets.all(1),
                    margin: YogaEdgeInsets.only(left: YogaValue.point(10)),
                    children: [
                      YogaLayout(
                        children: [
                          YogaItem(child: _buildBox("B1", Colors.purple)),
                        ],
                      ),
                      YogaLayout(
                        children: [
                          YogaItem(child: _buildBox("B2", Colors.purple)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '4. Block with fit-content',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Expectation: Width shrinks to fit content. Height expands to fit children.',
              ),
            ),
            Container(
              color: Colors.grey[200],
              width: double.infinity,
              child: Center(
                // Center to show fit-content effect
                child: YogaLayout(
                  display: YogaDisplay.block,
                  width: YogaValue.fitContent(),
                  padding: YogaEdgeInsets.all(YogaValue.point(10)),
                  background: YogaBackground(color: Colors.yellow[100]),
                  children: [
                    YogaLayout(
                      children: [
                        YogaItem(child: _buildBox("Wide Content", Colors.cyan)),
                      ],
                    ),
                    YogaLayout(
                      children: [
                        YogaItem(child: _buildBox("Short", Colors.cyan)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String text, Color color) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(8),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
