import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class AutoSizeHeightPage extends StatelessWidget {
  const AutoSizeHeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv 自动高度')),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 300,
            child: Align(
              alignment: Alignment.topLeft,
              child: HtmlDiv(
                width: const FixedSize(100),
                height: const AutoSize(),
                children: [
                  SizedBox(width: 50, height: 20),
                  SizedBox(width: 50, height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
