import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class MinContentWidthPage extends StatelessWidget {
  const MinContentWidthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv 最小内容宽度')),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const MinContent(),
            height: const AutoSize(),
            children: [
              SizedBox(width: 50, height: 20),
              SizedBox(width: 80, height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
