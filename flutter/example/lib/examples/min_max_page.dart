import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class MinMaxPage extends StatelessWidget {
  const MinMaxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Min/Max Dimensions')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Min Width (100pt)'),
            Container(
              color: Colors.grey[200],
              child: YogaLayout(
                useWebDefaults: true,
                width: YogaValue.percent(100),
                height: YogaValue.point(100),
                alignItems: YGAlign.center,
                justifyContent: YGJustify.center,
                children: [
                  YogaItem(
                    // Content is small, but minWidth forces it to be 100
                    minWidth: YogaValue.point(100),
                    height: YogaValue.point(50),
                    child: Container(
                      color: Colors.blue,
                      child: const Center(
                        child: Text(
                          'Small',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionTitle('2. Max Width (50%)'),
            Container(
              color: Colors.grey[200],
              child: YogaLayout(
                useWebDefaults: true,
                width: YogaValue.percent(100),
                height: YogaValue.point(100),
                alignItems: YGAlign.center,
                justifyContent: YGJustify.center,
                children: [
                  YogaItem(
                    // Content wants to be wide (long text), but maxWidth constrains it
                    maxWidth: YogaValue.pct(50),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.orange,
                      child: const Text(
                        'This is a very long text that should be constrained by maxWidth to 50% of the parent container.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionTitle('3. Min Height (100pt)'),
            Container(
              color: Colors.grey[200],
              child: YogaLayout(
                useWebDefaults: true,
                width: YogaValue.percent(100),
                height: YogaValue.point(150),
                alignItems: YGAlign.center,
                justifyContent: YGJustify.center,
                children: [
                  YogaItem(
                    width: YogaValue.point(100),
                    // Content is short, but minHeight forces it to be 100
                    minHeight: YogaValue.point(100),
                    child: Container(
                      color: Colors.green,
                      child: const Center(
                        child: Text(
                          'Short',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionTitle('4. Max Height (50pt)'),
            Container(
              color: Colors.grey[200],
              child: YogaLayout(
                useWebDefaults: true,
                width: YogaValue.percent(100),
                height: YogaValue.point(150),
                alignItems: YGAlign.center,
                justifyContent: YGJustify.center,
                children: [
                  YogaItem(
                    width: YogaValue.point(100),
                    // Content wants to be tall (height: 100), but maxHeight constrains it to 50
                    height: YogaValue.point(100),
                    maxHeight: YogaValue.point(50),
                    child: Container(
                      color: Colors.purple,
                      child: const Center(
                        child: Text(
                          'Tall',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionTitle('5. Min/Max on YogaLayout (Parent)'),
            YogaLayout(
              children: [
                YogaLayout(
                  useWebDefaults: true,
                  // Parent constraints
                  minWidth: YogaValue.point(400),
                  maxWidth: YogaValue.point(500),
                  height: YogaValue.point(100),
                  margin: YogaEdgeInsets.only(left: YogaValue.point(40)),
                  padding: const YogaEdgeInsets.all(YogaValue.point(20)),
                  border: YogaBorder.all(color: Colors.black, width: 2),
                  justifyContent: YGJustify.center,
                  alignItems: YGAlign.center,
                  children: [
                    YogaItem(
                      child: const Text(
                        "I am inside a container with minWidth 200 and maxWidth 300",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
