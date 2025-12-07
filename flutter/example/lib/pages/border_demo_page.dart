import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class BorderDemoPage extends StatelessWidget {
  const BorderDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv 边框示例')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BoxSizing 对比 (100x100, 10px Border)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('ContentBox (Total 120)'),
                      Container(
                        color: Colors.grey[200],
                        child: HtmlDiv(
                          width: const FixedSize(100),
                          height: const FixedSize(100),
                          boxSizing: HtmlBoxSizing.contentBox,
                          border: const HtmlBorder(
                            width: FixedBorderWidth(10),
                            style: HtmlBorderStyle.solid,
                            color: Colors.blue,
                          ),
                          children: [Container(color: Colors.blue.withValues(alpha: 0.2))],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('BorderBox (Total 100)'),
                      Container(
                        color: Colors.grey[200],
                        child: HtmlDiv(
                          width: const FixedSize(100),
                          height: const FixedSize(100),
                          boxSizing: HtmlBoxSizing.borderBox,
                          border: const HtmlBorder(
                            width: FixedBorderWidth(10),
                            style: HtmlBorderStyle.solid,
                            color: Colors.green,
                          ),
                          children: [Container(color: Colors.green.withValues(alpha: 0.2))],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 40),
              const Text('边框样式 (Border Styles)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildStyleDemo('Solid', HtmlBorderStyle.solid),
                  _buildStyleDemo('Dashed', HtmlBorderStyle.dashed),
                  _buildStyleDemo('Dotted', HtmlBorderStyle.dotted),
                  _buildStyleDemo('Double', HtmlBorderStyle.double),
                ],
              ),
              const Divider(height: 40),
              const Text('边框宽度类型', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Thin / Medium / Thick'),
              Row(
                children: [
                  _buildWidthDemo(const KeywordBorderWidth(BorderWidthKeyword.thin)),
                  const SizedBox(width: 10),
                  _buildWidthDemo(const KeywordBorderWidth(BorderWidthKeyword.medium)),
                  const SizedBox(width: 10),
                  _buildWidthDemo(const KeywordBorderWidth(BorderWidthKeyword.thick)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('百分比宽度 (10% of container)'),
              Container(
                width: 200,
                height: 100,
                color: Colors.grey[100],
                alignment: Alignment.center,
                child: HtmlDiv(
                  width: const FixedSize(100),
                  height: const FixedSize(50),
                  border: const HtmlBorder(
                    width: PercentBorderWidth(10),
                    style: HtmlBorderStyle.solid,
                    color: Colors.purple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleDemo(String label, HtmlBorderStyle style) {
    return Column(
      children: [
        Text(label),
        HtmlDiv(
          width: const FixedSize(80),
          height: const FixedSize(80),
          border: HtmlBorder(
            width: const FixedBorderWidth(5),
            style: style,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildWidthDemo(HtmlBorderWidth width) {
    return HtmlDiv(
      width: const FixedSize(50),
      height: const FixedSize(50),
      border: HtmlBorder(
        width: width,
        style: HtmlBorderStyle.solid,
        color: Colors.teal,
      ),
    );
  }
}
