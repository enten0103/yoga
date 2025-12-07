import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class PercentSizePage extends StatelessWidget {
  const PercentSizePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv 百分比尺寸布局')),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Center(
              child: HtmlDiv(
                width: const PercentSize(50),
                height: const PercentSize(25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
